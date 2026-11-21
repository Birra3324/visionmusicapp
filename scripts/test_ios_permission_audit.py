import plistlib
import tempfile
import unittest
from pathlib import Path
from audit_ios_permissions import audit


class PermissionAuditTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.app = Path(self.directory.name)
        self.write_info({'NSMicrophoneUsageDescription': 'Recognize a song.'})
        (self.app / 'Runner').write_bytes(bytes.fromhex('cffaedfe') + b' microphoneOnly')

    def write_info(self, value):
        (self.app / 'Info.plist').write_bytes(plistlib.dumps(value))

    def test_accepts_microphone_only(self):
        self.assertTrue(audit(self.app)['passed'])

    def test_rejects_authorization_in_embedded_framework(self):
        binary = self.app / 'Frameworks/Unexpected.framework/Unexpected'
        binary.parent.mkdir(parents=True)
        binary.write_bytes(bytes.fromhex('cffaedfe') + b'requestWhenInUseAuthorization')
        self.assertFalse(audit(self.app)['passed'])

    def test_rejects_location_description_or_missing_microphone(self):
        self.write_info({'NSMicrophoneUsageDescription': 'Record.',
                         'NSLocationWhenInUseUsageDescription': 'Unexpected.'})
        self.assertFalse(audit(self.app)['passed'])
        self.write_info({})
        self.assertFalse(audit(self.app)['passed'])


if __name__ == '__main__': unittest.main()
