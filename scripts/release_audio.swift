import CryptoKit
import Foundation

// AES-GCM combined format: 12-byte random nonce, ciphertext, 16-byte tag.
// The private manifest is a JSON array of {"source": "/local/file.mp3",
// "name": "gumgume.mp3"}. Keep that manifest outside the repository.
struct Source: Decodable { let source: String; let name: String }
struct Track: Codable { let name: String; let sha256: String; let content: Data }
struct Payload: Codable { let version: Int; let tracks: [Track] }

enum ReleaseError: Error { case invalid(String) }
let allowedNames: Set<String> = ["gumgume.mp3", "qondaala.m4a", "shilimii.m4a"]
func checkedName(_ name: String) -> Bool { allowedNames.contains(name) }
func digest(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}
func key() throws -> SymmetricKey {
    guard let value = ProcessInfo.processInfo.environment["VISION_AUDIO_KEY"],
          let bytes = Data(base64Encoded: value), bytes.count == 32 else {
        throw ReleaseError.invalid("VISION_AUDIO_KEY must be a base64-encoded 32-byte key")
    }
    return SymmetricKey(data: bytes)
}
func validated(_ tracks: [Track]) throws {
    guard tracks.count == allowedNames.count, Set(tracks.map(\.name)) == allowedNames,
          tracks.allSatisfy({ checkedName($0.name) && !$0.content.isEmpty && digest($0.content) == $0.sha256 }) else {
        throw ReleaseError.invalid("Invalid names, track count, or audio digests")
    }
}
func run() throws {
    let args = CommandLine.arguments
    guard args.count == 4 else { throw ReleaseError.invalid("Usage: release_audio.swift seal MANIFEST OUTPUT | open CIPHERTEXT REPO_ROOT") }
    let cryptoKey = try key()
    if args[1] == "seal" {
        let source = try JSONDecoder().decode([Source].self, from: Data(contentsOf: URL(fileURLWithPath: args[2])))
        guard source.count == allowedNames.count, Set(source.map(\.name)) == allowedNames else { throw ReleaseError.invalid("Invalid manifest") }
        let tracks = try source.map { item -> Track in
            let data = try Data(contentsOf: URL(fileURLWithPath: item.source))
            return Track(name: item.name, sha256: digest(data), content: data)
        }
        try validated(tracks)
        let clear = try JSONEncoder().encode(Payload(version: 1, tracks: tracks))
        guard let sealed = try AES.GCM.seal(clear, using: cryptoKey).combined else { throw ReleaseError.invalid("Encryption failed") }
        try sealed.write(to: URL(fileURLWithPath: args[3]), options: [.atomic, .completeFileProtection])
    } else if args[1] == "open" {
        let sealed = try AES.GCM.SealedBox(combined: Data(contentsOf: URL(fileURLWithPath: args[2])))
        let payload = try JSONDecoder().decode(Payload.self, from: AES.GCM.open(sealed, using: cryptoKey))
        guard payload.version == 1 else { throw ReleaseError.invalid("Unknown payload version") }
        try validated(payload.tracks)
        let root = URL(fileURLWithPath: args[3], isDirectory: true).resolvingSymlinksInPath().standardizedFileURL
        let assets = root.appendingPathComponent("assets", isDirectory: true)
        let attributes = try FileManager.default.attributesOfItem(atPath: assets.path)
        guard attributes[.type] as? FileAttributeType == .typeDirectory,
              assets.resolvingSymlinksInPath().standardizedFileURL == assets.standardizedFileURL else {
            throw ReleaseError.invalid("Assets must be a real directory within the workspace")
        }
        let directory = assets.appendingPathComponent("release_audio", isDirectory: true)
        guard (try? FileManager.default.attributesOfItem(atPath: directory.path)) == nil else { throw ReleaseError.invalid("Release audio directory already exists") }
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: false, attributes: [.posixPermissions: 0o700])
        do {
            for track in payload.tracks { try track.content.write(to: directory.appendingPathComponent(track.name), options: .atomic) }
        } catch { try? FileManager.default.removeItem(at: directory); throw error }
    } else { throw ReleaseError.invalid("Unknown operation") }
}
do { try run() } catch {
    FileHandle.standardError.write(Data("Release audio operation failed. Check the key, manifest, and authenticated archive.\n".utf8))
    exit(1)
}
