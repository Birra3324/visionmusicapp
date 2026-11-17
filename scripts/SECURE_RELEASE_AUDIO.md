# Protected iOS audio transport

This is a transport mechanism, not a release-ready catalog. The project must
separately declare the chosen `assets/release_audio/` MP3/M4A files in Flutter and
match each song's title and artist. Keep all original audio and the private
source manifest outside this public repository. `assets/release_audio/` is
ignored by Git.

1. Create a private JSON manifest outside the repository: an array of objects
   with `source` (absolute local audio path) and `name`. Exactly three names
   are accepted: `gumgume.mp3`, `qondaala.m4a`, and `shilimii.m4a`. These
   must match the reviewed app's asset paths. Use only verified lossy audio.
2. Generate a new random 32-byte key and preserve it securely as base64. Provide
   it in `VISION_AUDIO_KEY` to the local process without placing it in command
   history, the manifest, a Git commit, or logs. Run the Swift tool with
   `seal PRIVATE_MANIFEST release/secure_audio.enc`. Record the SHA-256 of the
   ciphertext in the checked-in file `release/secure_audio.sha256` as exactly
   64 lower-case hex characters. Review the staged files before committing: only the ciphertext,
   code and non-sensitive metadata should be staged, never the source or key.
3. Put the key in the `app-store` environment secret `VISION_AUDIO_KEY` through
   GitHub's secure secret entry. Do not paste it in chat. Existing signing
   secrets remain separately managed. The environment must require the owner's
   approval. Its branch policy is currently unrestricted; the reviewer must
   verify the exact commit and the team may separately configure a restriction.
4. Dispatch the existing `ios-release.yml` workflow on the reviewed
   `secure-release/` branch at the exact approved commit, setting its existing
   `ref` input to that same branch name. The environment
   reviewer must verify branch, commit, code, and hash before approving. The job
   checks out the workflow SHA, verifies the package digest, authenticates the
   AES-GCM tag, verifies each decrypted file's digest, and refuses unsafe paths
   or an existing output directory. It tests and builds with the bundled catalog.
5. Upload is optional. For an authorized upload, independently check App Store
   Connect and commit a new unused numeric build number in
   `release/build_number.txt`; workflow run numbers cannot guarantee uniqueness.
   Build 105 already exists.

The key is available only to the decrypt step, after environment approval. An
always step removes known plaintext assets, builds, derived data and signing
material, but tool-created temporary copies may remain and an abrupt failure
can prevent cleanup. Use GitHub-hosted ephemeral runners only. The ciphertext is still public and retained in Git history. A
later key leak exposes it. The distributed app contains playable audio; this
transport does not prevent a recipient from extracting bundled media. Do not
put decrypted assets or built apps into logs, caches or Actions artifacts.

Run `python3 scripts/test_release_audio.py` on macOS with Xcode to test synthetic
data. The tests cover round trip, nonce variation, tampering, wrong key, unsafe
paths, symlinked destinations, and refusal to overwrite an existing directory. They do not test
GitHub environment rules, signing, upload, or audio identity.
