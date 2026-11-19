import tempfile
import unittest
from pathlib import Path
from ci_audio_fixtures import FILES, cleanup, prepare


class FixtureTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.root.joinpath('pubspec.yaml').write_text(
            'flutter:\n  assets:\n' + ''.join(
                f'    - assets/release_audio/{name}\n' for name in FILES))

    def test_prepares_valid_synthetic_headers_and_removes_only_own_files(self):
        prepare(self.root)
        target = self.root / 'assets/release_audio'
        self.assertEqual((target / 'gumgume.mp3').read_bytes()[:3], b'ID3')
        self.assertEqual((target / 'qondaala.m4a').read_bytes()[4:8], b'ftyp')
        cleanup(self.root)
        self.assertFalse(target.exists())

    def test_existing_recordings_are_never_replaced(self):
        target = self.root / 'assets/release_audio'
        target.mkdir(parents=True)
        original = target / 'owner-data'
        original.write_text('preserve')
        with self.assertRaises(RuntimeError): prepare(self.root)
        with self.assertRaises(RuntimeError): cleanup(self.root)
        self.assertEqual(original.read_text(), 'preserve')

    def test_modified_fixture_is_preserved(self):
        prepare(self.root)
        changed = self.root / 'assets/release_audio/gumgume.mp3'
        changed.write_text('replacement')
        with self.assertRaises(RuntimeError): cleanup(self.root)
        self.assertEqual(changed.read_text(), 'replacement')


if __name__ == '__main__': unittest.main()
