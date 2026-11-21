# Synthetic silence for public CI

These files contain 0.25 seconds of generated silence, no music or recordings.
They were generated locally using FFmpeg's `anullsrc=r=22050:cl=mono` source,
encoded as 32 kbps MP3 (`libmp3lame`) and AAC (`aac`, M4A container).

`scripts/ci_audio_fixtures.py` copies them into the ignored release-audio paths
only for code validation. It refuses to replace existing media. No secret or
encrypted package is required. Do not distribute builds containing these files.
Public CI excludes the `protected_audio` test; the protected release workflow
continues to run that test against authenticated, decrypted originals.
