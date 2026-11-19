"""Prepare explicitly synthetic media for public code-only validation.

Never decrypts, reads, overwrites or publishes protected recordings. Production
media validation remains a separate tagged test in the protected workflow.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil

FIXTURES = Path(__file__).resolve().parent.parent / 'test/fixtures/audio'
FILES = {'gumgume.mp3': 'silence.mp3', 'qondaala.m4a': 'silence.m4a',
         'shilimii.m4a': 'silence.m4a'}
MARKER = '.synthetic-ci-audio.json'


def prepare(root):
    declared = set(re.findall(r'^\s+- assets/release_audio/(\S+)\s*$',
                             (root / 'pubspec.yaml').read_text(), re.MULTILINE))
    if not declared:
        print('No protected audio declarations; fixtures are unnecessary.')
        return
    if declared != set(FILES):
        raise RuntimeError('Unexpected release audio declarations; review fixture mapping.')
    target = root / 'assets/release_audio'
    if target.exists() or target.is_symlink():
        raise RuntimeError('Refusing to replace an existing release_audio path.')
    target.mkdir(parents=True, mode=0o700)
    hashes = {}
    for name, fixture in FILES.items():
        destination = target / name
        shutil.copyfile(FIXTURES / fixture, destination)
        hashes[name] = hashlib.sha256(destination.read_bytes()).hexdigest()
    (target / MARKER).write_text(json.dumps(hashes))
    print('SYNTHETIC AUDIO ONLY: three quarter-second silence fixtures prepared.')
    print('This validation does not establish release-media or playback readiness.')


def cleanup(root):
    target = root / 'assets/release_audio'
    if not target.exists():
        return
    marker = target / MARKER
    if target.is_symlink() or not marker.is_file() or marker.is_symlink():
        raise RuntimeError('Refusing to remove audio without our fixture marker.')
    hashes = json.loads(marker.read_text())
    if set(hashes) != set(FILES) or {p.name for p in target.iterdir()} != set(FILES) | {MARKER}:
        raise RuntimeError('Fixture directory changed; preserving it.')
    for name, digest in hashes.items():
        path = target / name
        expected = hashlib.sha256((FIXTURES / FILES[name]).read_bytes()).hexdigest()
        if path.is_symlink() or digest != expected or hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise RuntimeError('Fixture content changed; preserving it.')
    for name in FILES:
        (target / name).unlink()
    marker.unlink()
    target.rmdir()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['prepare', 'cleanup'])
    parser.add_argument('--synthetic-only', action='store_true', required=True)
    args = parser.parse_args()
    {'prepare': prepare, 'cleanup': cleanup}[args.action](Path.cwd())
