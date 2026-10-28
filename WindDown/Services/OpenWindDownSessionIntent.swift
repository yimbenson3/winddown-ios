import AppIntents
import Foundation

/// Runs when the user taps "Unwind" on the ringing alarm.
/// AlarmKit runs this in the app's process even if the app wasn't open,
/// then `openAppWhenRun` brings the app to the foreground.
struct OpenWindDownSessionIntent: LiveActivityIntent {
    static let pendingKey = "pendingWindDownSession"

    static var title: LocalizedStringResource = "Start wind-down session"
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        SharedStore.defaults.set(true, forKey: Self.pendingKey)
        return .result()
    }
}
