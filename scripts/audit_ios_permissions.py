"""Audit an unsigned built .app without reading bundled catalog/audio assets."""
import argparse
import json
from pathlib import Path
import plistlib

MACHO = {bytes.fromhex(h) for h in ['feedface', 'feedfacf', 'cefaedfe',
                                   'cffaedfe', 'cafebabe', 'bebafeca',
                                   'cafebabf', 'bfbafeca']}
FORBIDDEN = [b'requestWhenInUseAuthorization', b'requestAlwaysAuthorization',
             b'LocationPermissionStrategy', b'PermissionHandlerPlugin']


def audit(app):
    with (app / 'Info.plist').open('rb') as file:
        info = plistlib.load(file)
    location_keys = sorted(k for k in info if k.startswith('NSLocation'))
    microphone_description = bool(info.get('NSMicrophoneUsageDescription', '').strip())
    binaries = []
    references = []
    core_location = []
    for path in sorted(app.rglob('*')):
        if not path.is_file() or 'flutter_assets' in path.parts:
            continue
        with path.open('rb') as file:
            if file.read(4) not in MACHO:
                continue
            file.seek(0)
            data = file.read()
        name = str(path.relative_to(app))
        binaries.append(name)
        for token in FORBIDDEN:
            if token in data:
                references.append({'binary': name, 'reference': token.decode()})
        if b'CoreLocation.framework' in data or b'CLLocationManager' in data:
            core_location.append(name)
    passed = bool(binaries) and microphone_description and not location_keys and not references
    return {'passed': passed, 'microphoneUsageDescriptionPresent': microphone_description,
            'locationUsageKeys': location_keys, 'locationAuthorizationReferences': references,
            'coreLocationReferences': core_location, 'binariesScanned': binaries}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('app', type=Path)
    args = parser.parse_args()
    result = audit(args.app)
    print(json.dumps(result, indent=2))
    raise SystemExit(0 if result['passed'] else 1)
