import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Wraps the Screen Time API.
///
/// - FamilyControls: permission + the app picker
/// - DeviceActivity: tells the system "run my monitor extension at these times"
/// - ManagedSettings: actually puts the shield over the chosen apps
///
/// The shields are applied/removed by the WindDownMonitor extension at the start/end of the
/// window, so blocking still works when the app isn't running.
@MainActor
final class ScreenTimeService {
    private let center = DeviceActivityCenter()
    private let store = ManagedSettingsStore(named: .windDown)

    var isAuthorized: Bool {
        AuthorizationCenter.shared.authorizationStatus == .approved
    }

    func requestAuthorization() async throws {
        // `.individual` = the user is managing their own phone (not a parent/child setup).
        try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
    }

    func startMonitoring(_ schedule: WindDownSchedule) throws {
        let activitySchedule = DeviceActivitySchedule(
            intervalStart: schedule.startComponents,
            intervalEnd: schedule.endComponents,
            repeats: true
        )
        center.stopMonitoring([.windDown])
        try center.startMonitoring(.windDown, during: activitySchedule)
    }

    func stopMonitoring() {
        center.stopMonitoring([.windDown])
        store.clearAllSettings()
    }

    /// Handy for testing: block right now without waiting for the schedule.
    func shieldNow(_ selection: FamilyActivitySelection) {
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    func removeShields() {
        store.clearAllSettings()
    }
}
