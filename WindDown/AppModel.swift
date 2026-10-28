import SwiftUI
import FamilyControls

/// App-wide state. Views read and write through this; it persists via SharedStore
/// and keeps the alarm and Screen Time schedule in sync with the user's settings.
@MainActor
@Observable
final class AppModel {
    var schedule: WindDownSchedule = SharedStore.schedule
    var blockedSelection: FamilyActivitySelection = SharedStore.blockedSelection
    var isShowingSession = false
    var lastError: String?

    let alarms = AlarmService()
    let screenTime = ScreenTimeService()

    var hasCompletedOnboarding = SharedStore.defaults.bool(forKey: "hasCompletedOnboarding") {
        didSet { SharedStore.defaults.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    /// Ask for both permissions up front during onboarding.
    func requestPermissions() async {
        do {
            try await screenTime.requestAuthorization()
            try await alarms.requestAuthorization()
            hasCompletedOnboarding = true
        } catch {
            lastError = error.localizedDescription
        }
    }

    /// Save settings and (re)schedule everything.
    func apply() async {
        SharedStore.schedule = schedule
        SharedStore.blockedSelection = blockedSelection
        do {
            if schedule.isEnabled {
                try await alarms.scheduleWindDownAlarm(for: schedule)
                try screenTime.startMonitoring(schedule)
            } else {
                try alarms.cancelWindDownAlarm()
                screenTime.stopMonitoring()
            }
            lastError = nil
        } catch {
            lastError = error.localizedDescription
        }
    }

    func checkForPendingSession() {
        if SharedStore.defaults.bool(forKey: OpenWindDownSessionIntent.pendingKey) {
            SharedStore.defaults.set(false, forKey: OpenWindDownSessionIntent.pendingKey)
            isShowingSession = true
        }
    }
}
