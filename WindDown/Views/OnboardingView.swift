import SwiftUI

struct OnboardingView: View {
    @Environment(AppModel.self) private var model
    @State private var isRequesting = false

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            Image(systemName: "moon.stars.fill")
                .font(.system(size: 72))
                .foregroundStyle(.indigo)

            Text("Put the phone down.\nBreathe. Rest.")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                Label("A gentle alarm tells you when it's time to wind down.", systemImage: "alarm")
                Label("Apps you pick are paused until morning.", systemImage: "hand.raised")
                Label("A short breathing session helps you switch off.", systemImage: "wind")
            }
            .font(.body)
            .foregroundStyle(.secondary)

            Spacer()

            if let error = model.lastError {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                isRequesting = true
                Task {
                    await model.requestPermissions()
                    isRequesting = false
                }
            } label: {
                Text(isRequesting ? "Asking…" : "Get started")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .disabled(isRequesting)

            Text("We'll ask for Screen Time and Alarm access. Nothing leaves your phone.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
    }
}

#Preview {
    OnboardingView().environment(AppModel())
}
