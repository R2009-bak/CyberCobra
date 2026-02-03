import SwiftUI

// MARK: - Character Style
enum CharacterStyle: String, Codable, CaseIterable {
    case robot
    case alien
    case hero
    case wizard
}

struct CharacterProgressView: View {

    let progress: StudentTopicProgress
    let style: CharacterStyle
    let colorHue: Double

    @State private var breathe = false
    @State private var blink = false

    // MARK: - Progress level (0–4)
    private var level: Int {
        progress.completedLevels.count
    }

    // MARK: - Body
    var body: some View {
        robot
            .scaleEffect(breathe ? 1.0 : 0.96)
            .animation(
                .easeInOut(duration: 2).repeatForever(autoreverses: true),
                value: breathe
            )
            .onAppear {
                breathe = true
                startBlinking()
            }
    }

    // MARK: - Robot
    private var robot: some View {
        VStack(spacing: 6) {

            // 🧠 Head (L1)
            if level >= 1 {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(width: 28, height: 28)
                    .overlay(
                        Capsule()
                            .fill(bodyColor.opacity(0.45))
                    )
                    .overlay(eyes)
            }

            // 🧱 Body + Arms (L2–L3)
            if level >= 2 {
                bodyWithArms
            }

            // 🦵 Legs (L4)
            if level >= 4 {
                HStack(spacing: 10) {
                    leg
                    leg
                }
            }
        }
    }

    // MARK: - Body with correctly attached arms
    private var bodyWithArms: some View {
        RoundedRectangle(cornerRadius: 14)
            .fill(.ultraThinMaterial)
            .frame(width: 36, height: 46)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .fill(bodyColor.opacity(0.5))
            )
            .overlay {
                if level >= 3 {
                    HStack {
                        arm
                        Spacer()
                        arm
                    }
                    .frame(width: 56)   // ширина «плеч»
                }
            }
    }

    // MARK: - Eyes
    private var eyes: some View {
        Group {
            if blink {
                Capsule()
                    .frame(width: 14, height: 2)
            } else {
                HStack(spacing: 6) {
                    Circle().frame(width: 4, height: 4)
                    Circle().frame(width: 4, height: 4)
                }
            }
        }
        .foregroundColor(.white.opacity(0.9))
    }

    // MARK: - Arm (VisionOS-style)
    private var arm: some View {
        Capsule()
            .fill(.ultraThinMaterial)
            .frame(width: 8, height: 26)
            .overlay(
                Capsule()
                    .fill(bodyColor.opacity(0.45))
            )
    }

    // MARK: - Leg
    private var leg: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(bodyColor.opacity(0.85))
            .frame(width: 8, height: 18)
    }

    // MARK: - Blinking
    private func startBlinking() {
        Timer.scheduledTimer(withTimeInterval: 4, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.1)) {
                blink = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                blink = false
            }
        }
    }

    // MARK: - Base color (from topic)
    private var bodyColor: Color {
        Color(
            hue: min(max(colorHue, 0), 1),
            saturation: 0.4,
            brightness: 0.85
        )
    }
}
