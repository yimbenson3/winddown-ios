import SwiftUI

struct RootView: View {
    @Environment(AppModel.self) private var model

    var body: some View {
        @Bindable var model = model

        Group {
            if model.hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView()
            }
        }
        .fullScreenCover(isPresented: $model.isShowingSession) {
            BreathingSessionView()
        }
    }
}
