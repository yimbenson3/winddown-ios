import SwiftUI

/// A simple box-breathing session: inhale 4s, hold 4s, exhale 4s, hold 4s.
/// Swap in your own exercises, audio (AVFoundation) or guided content later.
struct BreathingSessionView: View {
    @Environment(\.dismiss) private var dismiss

    private enum Phase: CaseIterable {
        case inhale, holdIn, exhale, holdOut

        var label: String {
            switch self {
            case .inhale: "Breathe in"
            case .holdIn, .holdOut: "Hold"
            case .exhale: "Breathe out"
            }
        }

        var scale: CGFloat {
            switch self {
            case .inhale, .holdIn: 1.0
            case .exhale, .holdOut: 0.5
            }
        }
    }

    private let phaseSeconds = 4.0
    private let totalSeconds = 120.0   // 2-minute session

    @State private var phase: Phase = .holdOut
    @State private var elapsed = 0.0
    @State private var isFinished = false

    var body: some View {
        ZStack {
            LinearGradient(colors: [.indigo, .black], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 48) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 280, height: 280)
                    Circle()
                        .fill(.white.opacity(0.35))
                        .frame(width: 280, height: 280)
                        .scaleEffect(phase.scale)
                        .animation(.easeInOut(duration: phaseSeconds), value: phase)
                }

                Text(isFinished ? "Well done. Sleep well." : phase.label)
                    .font(.title.weight(.medium))
                    .foregroundStyle(.white)
                    .contentTransition(.opacity)
                    .animation(.easeInOut, value: phase)

                ProgressView(value: min(elapsed, totalSeconds), total: totalSeconds)
                    .tint(.white)
                    .padding(.horizontal, 48)

                Spacer()

                Button(isFinished ? "Done" : "End session") { dismiss() }
                    .buttonStyle(.bordered)
                    .tint(.white)
            }
            .padding()
        }
        .task { await run() }
        .persistentSystemOverlays(.hidden)
    }

    private func run() async {
        let phases = Phase.allCases
        var index = 0
        while elapsed < totalSeconds && !Task.isCancelled {
            phase = phases[index % phases.count]
            index += 1
            try? await Task.sleep(for: .seconds(phaseSeconds))
            elapsed += phaseSeconds
        }
        if !Task.isCancelled { isFinished = true }
    }
}

#Preview {
    BreathingSessionView()
}
