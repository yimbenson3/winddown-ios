import Foundation
import FamilyControls
import ManagedSettings
import DeviceActivity

/// Settings shared between the app and its Screen Time extensions.
/// Extensions run in their own process, so everything they need lives in the App Group.
enum SharedStore {
    static let appGroupID = "group.com.yimbenson3.winddown"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: appGroupID) ?? .standard
    }

    private enum Key {
        static let selection = "blockedAppsSelection"
        static let schedule = "windDownSchedule"
    }

    /// The apps and categories the user chose to block during wind-down.
    static var blockedSelection: FamilyActivitySelection {
        get {
            guard let data = defaults.data(forKey: Key.selection),
                  let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data)
            else { return FamilyActivitySelection() }
            return selection
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Key.selection)
            }
        }
    }

    /// When wind-down starts and ends each day.
    static var schedule: WindDownSchedule {
        get {
            guard let data = defaults.data(forKey: Key.schedule),
                  let schedule = try? JSONDecoder().decode(WindDownSchedule.self, from: data)
            else { return .default }
            return schedule
        }
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                defaults.set(data, forKey: Key.schedule)
            }
        }
    }
}

/// A daily wind-down window, e.g. 10:00 pm to 6:30 am.
struct WindDownSchedule: Codable, Equatable {
    var startHour: Int
    var startMinute: Int
    var endHour: Int
    var endMinute: Int
    var isEnabled: Bool

    static let `default` = WindDownSchedule(startHour: 22, startMinute: 0, endHour: 6, endMinute: 30, isEnabled: false)

    var startComponents: DateComponents { DateComponents(hour: startHour, minute: startMinute) }
    var endComponents: DateComponents { DateComponents(hour: endHour, minute: endMinute) }
}

extension ManagedSettingsStore.Name {
    /// Named store so wind-down shields can be cleared without touching anything else.
    static let windDown = Self("windDown")
}

extension DeviceActivityName {
    static let windDown = Self("windDown")
}
