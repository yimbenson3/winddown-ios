import DeviceActivity
import ManagedSettings
import FamilyControls

/// The system wakes this extension at the start and end of the wind-down window
/// (scheduled by ScreenTimeService.startMonitoring). It runs even if the app is closed.
///
/// Extensions have a tight memory limit (~6 MB), so keep this lightweight.
final class WindDownMonitorExtension: DeviceActivityMonitor {
    private let store = ManagedSettingsStore(named: .windDown)

    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        guard activity == .windDown else { return }

        let selection = SharedStore.blockedSelection
        store.shield.applications = selection.applicationTokens.isEmpty ? nil : selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty
            ? nil
            : .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens.isEmpty ? nil : selection.webDomainTokens
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        guard activity == .windDown else { return }
        store.clearAllSettings()
    }
}
