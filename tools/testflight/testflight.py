"""TestFlight public link helper (App Store Connect API).

ACTION=inspect  read-only report: builds, beta groups, what beta review needs.
ACTION=apply    create/enable the external "Public testers" group with a public
                link, add the newest valid build, fill missing beta review text
                from the app's existing App Store review details, and submit the
                build to Beta App Review.

Never prints personal contact details: only whether each field is set.
"""
import json, os, sys, time, urllib.error, urllib.request

import jwt

BUNDLE_ID = 'com.visionmusic.app'
GROUP_NAME = 'Public testers'
WHAT_TO_TEST = (
    'Play songs from Home and Search, switch the language to Afaan Oromo or '
    'Amharic in Profile, make a playlist, and watch music videos. Tell us if '
    'anything is slow, crashes or looks wrong.'
)
DESCRIPTION = (
    'Vision Music streams Afaan Oromo and Ethiopian music from Vision '
    'Entertainment. Testers can play songs, make playlists and watch music '
    'videos, with the app in Afaan Oromo, Amharic or English.'
)
PRIVACY_URL = 'https://visionmusic.et/privacy'
FEEDBACK_EMAIL = 'visionentertainment2020@gmail.com'  # public contact on visionmusic.et

ACTION = os.environ.get('ACTION', 'inspect')
API = 'https://api.appstoreconnect.apple.com'


def token():
    key = open(os.environ['KEY_FILE']).read()
    now = int(time.time())
    return jwt.encode(
        {'iss': os.environ['ASC_ISSUER_ID'], 'iat': now, 'exp': now + 1000,
         'aud': 'appstoreconnect-v1'},
        key, algorithm='ES256',
        headers={'kid': os.environ['ASC_KEY_ID'], 'typ': 'JWT'})


TOKEN = token()


def call(method, path, body=None, ok=(200, 201, 204)):
    data = json.dumps(body).encode() if body is not None else None
    req = urllib.request.Request(API + path, data=data, method=method, headers={
        'Authorization': 'Bearer ' + TOKEN, 'Content-Type': 'application/json'})
    try:
        with urllib.request.urlopen(req, timeout=60) as r:
            raw = r.read()
            return json.loads(raw) if raw else {}
    except urllib.error.HTTPError as e:
        text = e.read().decode('utf-8', 'replace')
        if e.code in ok:
            return {}
        print(f'::error::{method} {path.split("?")[0]} -> HTTP {e.code}: {text[:800]}')
        raise SystemExit(1)


def present(v):
    return 'set' if v not in (None, '', []) else 'MISSING'


app = call('GET', f'/v1/apps?filter[bundleId]={BUNDLE_ID}')['data']
if not app:
    print('::error::App not found for', BUNDLE_ID); sys.exit(1)
app_id = app[0]['id']
print('App:', app[0]['attributes'].get('name'), BUNDLE_ID)

builds = call('GET', f'/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=8'
              '&include=preReleaseVersion,buildBetaDetail')
pre = {i['id']: i['attributes'] for i in builds.get('included', []) if i['type'] == 'preReleaseVersions'}
bbd = {i['id']: i['attributes'] for i in builds.get('included', []) if i['type'] == 'buildBetaDetails'}
print('\nBuilds (newest first):')
for b in builds['data']:
    a = b['attributes']
    pv = pre.get(b['relationships']['preReleaseVersion']['data']['id'], {}) if b['relationships'].get('preReleaseVersion', {}).get('data') else {}
    det = bbd.get(b['relationships']['buildBetaDetail']['data']['id'], {}) if b['relationships'].get('buildBetaDetail', {}).get('data') else {}
    print(f"  {pv.get('version')} ({a.get('version')}) state={a.get('processingState')} expired={a.get('expired')} "
          f"uploaded={a.get('uploadedDate','')[:16]} external={det.get('externalBuildState')} internal={det.get('internalBuildState')}")

groups = call('GET', f'/v1/apps/{app_id}/betaGroups?limit=50')['data']
print('\nBeta groups:')
for g in groups:
    a = g['attributes']
    print(f"  {a['name']} internal={a.get('isInternalGroup')} publicLink={a.get('publicLinkEnabled')} "
          f"link={a.get('publicLink') if a.get('publicLinkEnabled') else '-'}")

loc = call('GET', f'/v1/apps/{app_id}/betaAppLocalizations')['data']
print('\nBeta app info:')
for l in loc:
    a = l['attributes']
    print(f"  {a['locale']}: description={present(a.get('description'))} feedbackEmail={present(a.get('feedbackEmail'))} "
          f"privacyPolicyUrl={present(a.get('privacyPolicyUrl'))}")
if not loc:
    print('  none yet')

rd = call('GET', f'/v1/apps/{app_id}/betaAppReviewDetail')['data']
ra = rd['attributes']
print('Beta review contact:', {k: present(ra.get(k)) for k in
      ('contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail')},
      'demoAccountRequired=', ra.get('demoAccountRequired'))

# Existing App Store review contact (from earlier App Store submissions).
store = {}
versions = call('GET', f'/v1/apps/{app_id}/appStoreVersions?limit=5')['data']
for v in versions:
    d = call('GET', f"/v1/appStoreVersions/{v['id']}/appStoreReviewDetail", ok=(200, 404)).get('data')
    if d and d['attributes'].get('contactEmail'):
        store = d['attributes']; break
print('App Store review contact on file:', {k: present(store.get(k)) for k in
      ('contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail')})

subs = call('GET', f'/v1/betaAppReviewSubmissions?filter[build]={",".join(b["id"] for b in builds["data"])}&include=build')['data'] if builds['data'] else []
print('Beta review submissions:', [s['attributes'].get('betaReviewState') for s in subs] or 'none')

if ACTION != 'apply':
    print('\nInspect only. Nothing was changed.')
    sys.exit(0)

# ---------------- apply ----------------
valid = [b for b in builds['data'] if b['attributes'].get('processingState') == 'VALID' and not b['attributes'].get('expired')]
if not valid:
    print('::error::No processed, unexpired build to share.'); sys.exit(1)
build = valid[0]
print('\nUsing build', build['attributes']['version'])

missing = [k for k in ('contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail')
           if not ra.get(k) and not store.get(k)]
if missing:
    print('::error::Beta review contact missing and no App Store contact on file:', missing); sys.exit(1)

# 1. Beta review contact: reuse the App Store review contact where beta's is empty.
attrs = {k: (ra.get(k) or store.get(k)) for k in ('contactFirstName', 'contactLastName', 'contactPhone', 'contactEmail')}
attrs['demoAccountRequired'] = False
call('PATCH', f"/v1/betaAppReviewDetails/{rd['id']}", {'data': {'type': 'betaAppReviewDetails', 'id': rd['id'], 'attributes': attrs}})
print('Beta review contact: set (copied from existing details)')

# 2. Beta app description, feedback email, privacy link (only fill what's empty).
en = next((l for l in loc if l['attributes']['locale'].startswith('en')), None)
want = {'description': DESCRIPTION, 'feedbackEmail': FEEDBACK_EMAIL, 'privacyPolicyUrl': PRIVACY_URL}
if en:
    fill = {k: v for k, v in want.items() if not en['attributes'].get(k)}
    if fill:
        call('PATCH', f"/v1/betaAppLocalizations/{en['id']}", {'data': {'type': 'betaAppLocalizations', 'id': en['id'], 'attributes': fill}})
else:
    call('POST', '/v1/betaAppLocalizations', {'data': {'type': 'betaAppLocalizations',
         'attributes': dict(locale='en-US', **want),
         'relationships': {'app': {'data': {'type': 'apps', 'id': app_id}}}}})
print('Beta app info: set')

# 3. What to test, for this build.
bl = call('GET', f"/v1/builds/{build['id']}/betaBuildLocalizations")['data']
enb = next((l for l in bl if l['attributes']['locale'].startswith('en')), None)
if enb:
    if not enb['attributes'].get('whatsNew'):
        call('PATCH', f"/v1/betaBuildLocalizations/{enb['id']}", {'data': {'type': 'betaBuildLocalizations', 'id': enb['id'], 'attributes': {'whatsNew': WHAT_TO_TEST}}})
else:
    call('POST', '/v1/betaBuildLocalizations', {'data': {'type': 'betaBuildLocalizations',
         'attributes': {'locale': 'en-US', 'whatsNew': WHAT_TO_TEST},
         'relationships': {'build': {'data': {'type': 'builds', 'id': build['id']}}}}})
print('What to test: set')

# 4. External group with a public link.
group = next((g for g in groups if not g['attributes'].get('isInternalGroup') and g['attributes'].get('publicLinkEnabled')), None) \
    or next((g for g in groups if g['attributes']['name'] == GROUP_NAME), None)
if group is not None:
    print('Using external group', group['attributes']['name'])
if group is None:
    group = call('POST', '/v1/betaGroups', {'data': {'type': 'betaGroups',
        'attributes': {'name': GROUP_NAME, 'publicLinkEnabled': True, 'publicLinkLimitEnabled': False},
        'relationships': {'app': {'data': {'type': 'apps', 'id': app_id}}}}})['data']
    print('Created group', GROUP_NAME)
elif not group['attributes'].get('publicLinkEnabled'):
    group = call('PATCH', f"/v1/betaGroups/{group['id']}", {'data': {'type': 'betaGroups', 'id': group['id'],
        'attributes': {'publicLinkEnabled': True}}})['data']
call('POST', f"/v1/betaGroups/{group['id']}/relationships/builds",
     {'data': [{'type': 'builds', 'id': build['id']}]}, ok=(204, 409))
print('Build added to', GROUP_NAME)

# 5. Submit the build to Beta App Review (skip if already submitted/approved).
existing = [s for s in subs if s['relationships'].get('build', {}).get('data', {}).get('id') == build['id']] if subs else []
state = None
if not existing:
    r = call('POST', '/v1/betaAppReviewSubmissions', {'data': {'type': 'betaAppReviewSubmissions',
         'relationships': {'build': {'data': {'type': 'builds', 'id': build['id']}}}}}, ok=(201, 409))
    state = (r.get('data') or {}).get('attributes', {}).get('betaReviewState')
    print('Submitted to Beta App Review:', state or 'already in review')
else:
    print('Beta App Review already:', existing[0]['attributes'].get('betaReviewState'))

g = call('GET', f"/v1/betaGroups/{group['id']}")['data']['attributes']
print('\nPUBLIC LINK:', g.get('publicLink'), '| enabled:', g.get('publicLinkEnabled'))
print('Testers can open it once Apple approves the build for external testing.')
