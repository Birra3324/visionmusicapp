# VisionMusic TestFlight Readiness Checklist

## Code and build

- [x] Public Audio Master entry removed
- [x] Analyzer clean
- [x] Automated tests green
- [x] Privacy-safe analytics service added
- [x] Crashlytics integration added
- [x] App Check client integration added
- [x] Published-only catalog policy added
- [x] Simulator build after observability/localization changes
- [x] Signed physical-device build after observability/localization changes
- [x] Signed build installed and launched on `Birra iphone`
- [ ] Archive/IPA validation
- [ ] Upload dSYM files and confirm readable Crashlytics symbols

## Firebase and backend

- [ ] Backend team deploys published/approved Firestore read rules
- [ ] Backend team deploys Storage rules for approved public renditions
- [ ] Create required Firestore composite indexes
- [ ] Confirm Blaze billing budget alerts
- [ ] Enable Analytics in the Firebase project
- [ ] Confirm Crashlytics test event
- [ ] Review App Check monitoring metrics before enforcement
- [ ] Enable remote catalog only after production data passes validation

## Content

- [ ] Remove or replace every `REPLACE_` YouTube placeholder
- [ ] Validate audio URLs, artwork URLs, duration, artist, album, and rights metadata
- [ ] Confirm only owned/licensed content is published
- [ ] Confirm official YouTube playback and attribution
- [ ] Review explicit-content flags and age rating

## Product and legal

- [ ] Privacy policy URL live
- [ ] Terms/support URL live
- [ ] Account deletion works end-to-end
- [ ] App Privacy answers match actual Analytics/Crashlytics collection
- [ ] App Store screenshots and description finalized
- [ ] Support contact monitored

## Human QA

- [ ] Small iPhone layout
- [ ] Large iPhone layout
- [ ] Afaan Oromo visual pass and native-speaker review
- [ ] Arabic RTL visual pass
- [ ] Slow/offline network
- [ ] Background audio and lock screen
- [ ] Headphones/Bluetooth/interruption handling
- [ ] Search, favorite, playlist, video, and account flows
- [ ] No listener-visible admin/developer controls
