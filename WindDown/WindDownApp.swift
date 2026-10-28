import SwiftUI

@main
struct WindDownApp: App {
    @State private var model = AppModel()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(model)
                .onChange(of: scenePhase) { _, phase in
                    // When the user taps "Unwind" on the alarm, the intent sets a flag
                    // and opens the app; we pick it up here and show the session.
                    if phase == .active { model.checkForPendingSession() }
                }
        }
    }
}
