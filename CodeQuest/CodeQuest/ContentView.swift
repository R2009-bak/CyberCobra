import SwiftUI

// MARK: - Фон приложения
struct AppBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 0.95, green: 0.96, blue: 0.98),
                Color(red: 0.90, green: 0.93, blue: 0.97)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

// MARK: - Стеклянная карточка
struct GlassCard: View {
    let title: String
    let subtitle: String
    let icon: String

    @State private var pressed = false

    var body: some View {
        HStack(spacing: 16) {

            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Color(red: 0.45, green: 0.35, blue: 0.75))
                .scaleEffect(pressed ? 1.1 : 1.0)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(pressed ? 0.85 : 0.7))
                .shadow(
                    color: Color.purple.opacity(pressed ? 0.25 : 0.15),
                    radius: pressed ? 12 : 8,
                    y: pressed ? 8 : 4
                )
        )
        .scaleEffect(pressed ? 1.03 : 1.0)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: pressed)
        .onLongPressGesture(
            minimumDuration: 0.01,
            pressing: { isPressing in
                pressed = isPressing
            },
            perform: {}
        )
    }
}
