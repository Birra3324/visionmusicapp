#!/usr/bin/env python3
"""Synthetic-only round trip and integrity checks; writes only in a temp dir."""
import base64
import json
import os
from pathlib import Path
import subprocess
import tempfile

ROOT = Path(__file__).resolve().parent.parent

with tempfile.TemporaryDirectory(prefix="vision-audio-test-") as directory:
    temp = Path(directory)
    binary = temp / "release_audio"
    sdk = subprocess.check_output(["xcrun", "--sdk", "macosx", "--show-sdk-path"], text=True).strip()
    subprocess.run(["xcrun", "swiftc", "-sdk", sdk, str(ROOT / "scripts/release_audio.swift"), "-o", str(binary)], check=True)
    env = os.environ.copy()
    env["VISION_AUDIO_KEY"] = base64.b64encode(os.urandom(32)).decode()
    source = temp / "sample.mp3"
    source.write_bytes(b"Synthetic test data; not a song.\x00\xff")
    second_source = temp / "sample.m4a"
    second_source.write_bytes(b"A different synthetic file.")
    third_source = temp / "other.m4a"
    third_source.write_bytes(b"Third synthetic track.")
    manifest = temp / "manifest.json"
    manifest.write_text(json.dumps([{"source": str(source), "name": "gumgume.mp3"}, {"source": str(second_source), "name": "qondaala.m4a"}, {"source": str(third_source), "name": "shilimii.m4a"}]))
    package = temp / "package.enc"

    def invoke(*args, environment=env, ok=True):
        result = subprocess.run([str(binary), *map(str, args)], env=environment, capture_output=True)
        assert (result.returncode == 0) == ok, (args[0], result.returncode)

    invoke("seal", manifest, package)
    second = temp / "second.enc"
    invoke("seal", manifest, second)
    assert package.read_bytes() != second.read_bytes(), "encryption must use a fresh nonce"
    restored = temp / "restored"
    (restored / "assets").mkdir(parents=True)
    invoke("open", package, restored)
    assert (restored / "assets/release_audio/gumgume.mp3").read_bytes() == source.read_bytes()
    assert (restored / "assets/release_audio/qondaala.m4a").read_bytes() == second_source.read_bytes()
    assert (restored / "assets/release_audio/shilimii.m4a").read_bytes() == third_source.read_bytes()
    invoke("open", package, restored, ok=False)  # never overwrite existing audio

    damaged = bytearray(package.read_bytes())
    damaged[len(damaged) // 2] ^= 1
    corrupt = temp / "corrupt.enc"
    corrupt.write_bytes(damaged)
    rejected = temp / "rejected"
    invoke("open", corrupt, rejected, ok=False)
    assert not (rejected / "assets/release_audio").exists()
    wrong_env = dict(env, VISION_AUDIO_KEY=base64.b64encode(os.urandom(32)).decode())
    invoke("open", package, rejected, environment=wrong_env, ok=False)
    outside = temp / "outside"
    outside.mkdir()
    redirected = temp / "redirected"
    redirected.mkdir()
    (redirected / "assets").symlink_to(outside, target_is_directory=True)
    invoke("open", package, redirected, ok=False)
    assert not (outside / "release_audio").exists()
    dangling = temp / "dangling"
    (dangling / "assets").mkdir(parents=True)
    (dangling / "assets/release_audio").symlink_to(temp / "nonexistent", target_is_directory=True)
    invoke("open", package, dangling, ok=False)
    manifest.write_text(json.dumps([{"source": str(source), "name": "../escape.mp3"}]))
    invoke("seal", manifest, temp / "invalid.enc", ok=False)
    assert not (temp / "invalid.enc").exists()
    print("Synthetic round-trip, nonce, tamper, wrong-key, overwrite, symlink and path checks passed.")
