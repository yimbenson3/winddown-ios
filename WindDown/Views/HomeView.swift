import SwiftUI
import FamilyControls

struct HomeView: View {
    @Environment(AppModel.self) private var model
    @State private var isPickerPresented = false

    var body: some View {
        @Bindable var model = model

        NavigationStack {
            Form {
                Section {
                    Toggle("Nightly wind-down", isOn: $model.schedule.isEnabled)
                    DatePicker("Starts", selection: startBinding, displayedComponents: .hourAndMinute)
                    DatePicker("Ends", selection: endBinding, displayedComponents: .hourAndMinute)
                } footer: {
                    Text("An alarm rings at the start time, and your chosen apps stay paused until the end time.")
                }

                Section("Apps to pause") {
                    Button {
                        isPickerPresented = true
                    } label: {
                        LabeledContent("Choose apps", value: selectionSummary)
                    }
                }

                Section {
                    Button("Start a breathing session now") {
                        model.isShowingSession = true
                    }
                }

                if let error = model.lastError {
                    Section {
                        Text(error).foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("WindDown")
            .familyActivityPicker(isPresented: $isPickerPresented, selection: $model.blockedSelection)
            .onChange(of: model.schedule) { _, _ in Task { await model.apply() } }
            .onChange(of: model.blockedSelection) { _, _ in Task { await model.apply() } }
        }
    }

    private var selectionSummary: String {
        let apps = model.blockedSelection.applicationTokens.count
        let categories = model.blockedSelection.categoryTokens.count
        if apps == 0 && categories == 0 { return "None" }
        return "\(apps) apps, \(categories) categories"
    }

    // DatePicker works with Date, our schedule stores hour/minute.
    private var startBinding: Binding<Date> {
        Binding(
            get: { Self.date(hour: model.schedule.startHour, minute: model.schedule.startMinute) },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.schedule.startHour = parts.hour ?? 22
                model.schedule.startMinute = parts.minute ?? 0
            }
        )
    }

    private var endBinding: Binding<Date> {
        Binding(
            get: { Self.date(hour: model.schedule.endHour, minute: model.schedule.endMinute) },
            set: { date in
                let parts = Calendar.current.dateComponents([.hour, .minute], from: date)
                model.schedule.endHour = parts.hour ?? 6
                model.schedule.endMinute = parts.minute ?? 30
            }
        )
    }

    private static func date(hour: Int, minute: Int) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: .now) ?? .now
    }
}

#Preview {
    HomeView().environment(AppModel())
}
