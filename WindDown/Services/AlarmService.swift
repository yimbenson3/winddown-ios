import Foundation
import SwiftUI
import AlarmKit

/// Metadata attached to our alarms. Empty for now; add fields (e.g. a session type)
/// if you later want the Live Activity or intents to know more about the alarm.
struct WindDownAlarmMetadata: AlarmMetadata {}

/// Wraps AlarmKit (iOS 26+). AlarmKit alarms ring through Silent mode and Focus,
/// even when the app is closed — that's why this app needs iOS 26.
@MainActor
final class AlarmService {
    private let manager = AlarmManager.shared
    private let alarmIDKey = "windDownAlarmID"

    func requestAuthorization() async throws {
        switch manager.authorizationState {
        case .authorized:
            return
        case .notDetermined:
            let state = try await manager.requestAuthorization()
            if state != .authorized { throw AlarmServiceError.notAuthorized }
        case .denied:
            throw AlarmServiceError.notAuthorized
        @unknown default:
            throw AlarmServiceError.notAuthorized
        }
    }

    /// Schedules a daily alarm at the start of the wind-down window.
    func scheduleWindDownAlarm(for schedule: WindDownSchedule) async throws {
        try await requestAuthorization()
        try cancelWindDownAlarm()

        // What the alarm looks like on the Lock Screen / Dynamic Island.
        let alert = AlarmPresentation.Alert(
            title: "Time to wind down",
            stopButton: AlarmButton(text: "Dismiss", textColor: .white, systemImageName: "xmark"),
            secondaryButton: AlarmButton(text: "Unwind", textColor: .white, systemImageName: "leaf.fill"),
            secondaryButtonBehavior: .custom
        )

        let attributes = AlarmAttributes<WindDownAlarmMetadata>(
            presentation: AlarmPresentation(alert: alert),
            tintColor: .indigo
        )

        // Repeat every day at the start time.
        let time = Alarm.Schedule.Relative.Time(hour: schedule.startHour, minute: schedule.startMinute)
        let alarmSchedule = Alarm.Schedule.relative(
            .init(time: time, repeats: .weekly(Locale.Weekday.allCases))
        )

        let id = UUID()
        let configuration = AlarmManager.AlarmConfiguration<WindDownAlarmMetadata>(
            schedule: alarmSchedule,
            attributes: attributes,
            secondaryIntent: OpenWindDownSessionIntent()   // "Unwind" opens the breathing session
        )

        _ = try await manager.schedule(id: id, configuration: configuration)
        SharedStore.defaults.set(id.uuidString, forKey: alarmIDKey)
    }

    func cancelWindDownAlarm() throws {
        guard let raw = SharedStore.defaults.string(forKey: alarmIDKey),
              let id = UUID(uuidString: raw) else { return }
        try? manager.cancel(id: id)
        SharedStore.defaults.removeObject(forKey: alarmIDKey)
    }
}

enum AlarmServiceError: LocalizedError {
    case notAuthorized

    var errorDescription: String? {
        "WindDown doesn't have permission to set alarms. You can turn it on in Settings > WindDown."
    }
}
