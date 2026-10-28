# WindDown

An iOS wellness app that works like an alarm clock for going to bed: at a time you choose, a gentle alarm rings, your distracting apps are paused, and a short breathing session helps you put the phone down and relax.

> **Status:** starter scaffold. The code was written without access to a Mac, so expect to fix a few compile errors the first time you build (see [Known rough edges](#known-rough-edges)).

## What's in here

```
winddown-ios/
├── project.yml                     # XcodeGen spec → generates WindDown.xcodeproj
├── WindDown/                       # the main app
│   ├── WindDownApp.swift           # entry point
│   ├── AppModel.swift              # app state; keeps alarm + blocking in sync with settings
│   ├── Services/
│   │   ├── AlarmService.swift      # AlarmKit: schedules the nightly alarm
│   │   ├── ScreenTimeService.swift # FamilyControls / DeviceActivity / ManagedSettings
│   │   └── OpenWindDownSessionIntent.swift  # "Unwind" button on the alarm → opens a session
│   ├── Views/
│   │   ├── RootView.swift
│   │   ├── OnboardingView.swift    # explains the app, asks for permissions
│   │   ├── HomeView.swift          # schedule + app picker
│   │   └── BreathingSessionView.swift  # 2-minute box-breathing animation
│   └── Assets.xcassets
├── Shared/
│   └── SharedStore.swift           # settings stored in an App Group so extensions can read them
└── Extensions/
    ├── WindDownMonitor/            # system wakes this at start/end of wind-down → applies/removes shields
    └── WindDownShield/             # the custom screen shown over a paused app
```

### How the pieces fit

1. The user picks a wind-down window (e.g. 10:00 pm – 6:30 am) and the apps to pause.
2. **AlarmKit** schedules a daily alarm at the start time. It rings through Silent mode and Focus, even if the app is closed.
3. **DeviceActivity** tells iOS to wake the **WindDownMonitor** extension at the start and end of the window.
4. At the start, the extension uses **ManagedSettings** to shield the chosen apps. At the end, it removes the shields.
5. Opening a paused app shows the **WindDownShield** screen instead.
6. Tapping **Unwind** on the alarm opens the app straight into the breathing session.

## What you need

| Item | Notes |
|---|---|
| A Mac | Xcode only runs on macOS |
| Xcode 26 or later | Free from the Mac App Store |
| An iPhone on iOS 26+ | AlarmKit and Screen Time don't work properly in the Simulator |
| Apple Developer Program membership | Paid yearly. Needed for TestFlight, the App Store, and the Family Controls distribution entitlement. You can start on a free Apple ID for local testing. |
| XcodeGen | `brew install xcodegen` |

## Steps to get it running

### 1. Clone and generate the Xcode project

```bash
git clone <this repo>
cd winddown-ios
brew install xcodegen      # once
xcodegen generate
open WindDown.xcodeproj
```

Re-run `xcodegen generate` whenever you add files or change `project.yml`. The `.xcodeproj` is generated, so it's git-ignored.

### 2. Set your identifiers

In `project.yml`:

- `bundleIdPrefix` and every `PRODUCT_BUNDLE_IDENTIFIER`: change `com.yimbenson3` to something you own (e.g. `ca.yourname`). Bundle IDs must be globally unique.
- The App Group `group.com.yimbenson3.winddown`: change it in `project.yml` (three places) **and** `Shared/SharedStore.swift`. They must match exactly.
- `DEVELOPMENT_TEAM`: your Team ID (Xcode → Settings → Accounts → your team). Or leave it blank and pick the team in Xcode under *Signing & Capabilities* for each of the three targets.

Then `xcodegen generate` again.

### 3. Sign in and register capabilities

1. In Xcode → Settings → Accounts, add your Apple ID.
2. For **each target** (WindDown, WindDownMonitor, WindDownShield), open *Signing & Capabilities* and check that:
   - *Automatically manage signing* is on and your team is selected.
   - **Family Controls** and **App Groups** are listed (the group you set in step 2 is ticked).
3. Xcode registers the bundle IDs and App Group in your developer account for you.

### 4. Run on your iPhone

1. Turn on **Developer Mode** on the phone (Settings → Privacy & Security → Developer Mode) and plug it in.
2. Pick your iPhone as the run destination and press ⌘R.
3. In the app: tap **Get started**, allow Screen Time access and alarms, choose a start time a couple of minutes from now, pick an app to pause, and turn on **Nightly wind-down**.
4. Lock the phone and wait for the alarm. Then try opening the paused app.

### 5. Request the Family Controls distribution entitlement (do this early)

Development builds work without approval, but **you can't ship to TestFlight or the App Store until Apple approves the Family Controls (Distribution) entitlement.** Approval can take a week or more.

1. Go to <https://developer.apple.com/contact/request/family-controls-distribution>.
2. Submit a request for the main app bundle ID **and** a separate one for each extension (`.monitor` and `.shield`).
3. Once approved, in Certificates, Identifiers & Profiles, enable *Family Controls (Distribution)* on each bundle ID.

You'll need a privacy policy URL for the request. A simple GitHub Pages site works.

### 6. Test with friends (TestFlight)

1. Create the app in [App Store Connect](https://appstoreconnect.apple.com) using the main bundle ID.
2. In Xcode: Product → Archive → Distribute App → TestFlight & App Store.
3. Add testers in App Store Connect.

### 7. Automate builds (optional, but your strength)

- **Xcode Cloud** (built into App Store Connect) is the least setup.
- **fastlane + GitHub Actions** on a `macos` runner gives you more control: `fastlane match` for signing, `gym` to build, `pilot` to upload to TestFlight. Have the workflow run `xcodegen generate` first.
- Code signing is the hard part: three targets, each with its own bundle ID, App Group, and Family Controls entitlement.

### 8. Ship to the App Store

- App icon (1024×1024 PNG in `Assets.xcassets/AppIcon`), screenshots, description, keywords.
- Privacy policy and the App Privacy "nutrition label." If you collect nothing, say so.
- In the review notes, explain why you use Screen Time and alarms. Apple reviews screen-time apps closely.

## Ideas for after the MVP

- **Live Activity / widget extension** for AlarmKit, so the alarm can show a countdown in the Dynamic Island.
- **ShieldAction extension** so the shield's button can open WindDown's breathing session.
- Calming audio (AVFoundation) and more exercises (body scan, 4-7-8 breathing).
- Save sessions to HealthKit as *Mindful Minutes*.
- Streaks and a weekly summary (DeviceActivityReport extension).
- Subscription with StoreKit 2.
- Rename the app: search the project for `WindDown` and update `project.yml`.

## Known rough edges

- **Not compiled yet.** AlarmKit is new and its API has shifted between iOS 26 point releases. If `AlarmPresentation.Alert` or `AlarmManager.AlarmConfiguration` don't compile, check Apple's sample *Scheduling an alarm with AlarmKit* and adjust `AlarmService.swift`.
- **Swift 5 language mode** is set to avoid strict-concurrency errors while you learn. Switch `SWIFT_VERSION` to `6.0` later.
- Users can revoke Screen Time access in Settings at any time. Check `ScreenTimeService.isAuthorized` on launch and show onboarding again if it's been turned off.
- Screen Time extensions have a very small memory limit (about 6 MB). Keep them lean.
- AlarmKit alarms use the ringer volume. Remind users to turn it up.

## Useful links

- [AlarmKit documentation](https://developer.apple.com/documentation/alarmkit)
- [Screen Time API overview](https://developer.apple.com/documentation/screentimeapidocumentation)
- [Configuring Family Controls](https://developer.apple.com/documentation/xcode/configuring-family-controls)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- [Apple's SwiftUI tutorials](https://developer.apple.com/tutorials/swiftui)
