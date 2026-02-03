import SwiftUI

struct RoleSelectionView: View {

    @State private var animate = false
    @State private var showAdminPassword = false
    @State private var showAdminScreen = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 28) {

                    header
                    FloatingCode()
                        .opacity(animate ? 1 : 0)
                        .animation(.easeInOut(duration: 0.6), value: animate)

                    robot

                    roleButtons
                }
                .padding(.horizontal)
            }
            .onAppear { animate = true }
            .sheet(isPresented: $showAdminPassword) {
                AdminPasswordSheet {
                    showAdminPassword = false
                    showAdminScreen = true
                }
            }
            .navigationDestination(isPresented: $showAdminScreen) {
                AdminLoginView()
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("CodeQuest")
                .font(.system(size: 46, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.55, green: 0.45, blue: 0.85),
                            Color(red: 0.35, green: 0.65, blue: 0.95)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Algorithms • Programming")
                .font(.system(size: 15, design: .monospaced))
                .foregroundColor(.secondary)
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : -12)
        .animation(.easeOut(duration: 0.6), value: animate)
    }

    // MARK: - Robot
    private var robot: some View {
        RobotLottieView()
            .frame(width: 240, height: 240)
            .scaleEffect(animate ? 1 : 0.95)
            .opacity(animate ? 1 : 0)
            .animation(.easeOut(duration: 0.7), value: animate)
    }

    // MARK: - Role Buttons
    private var roleButtons: some View {
        VStack(spacing: 14) {

            Button {
                showAdminPassword = true
            } label: {
                RoleButton(
                    title: "Администратор",
                    subtitle: "Управление темами и уровнями",
                    icon: "lock.fill"
                )
            }

            NavigationLink {
                StudentHomeView()
            } label: {
                RoleButton(
                    title: "Ученик",
                    subtitle: "Обучение, тест и квест",
                    icon: "graduationcap.fill"
                )
            }
        }
        .opacity(animate ? 1 : 0)
        .offset(y: animate ? 0 : 20)
        .animation(
            .spring(response: 0.6, dampingFraction: 0.75),
            value: animate
        )
    }
}

struct AdminPasswordSheet: View {

    @Environment(\.dismiss) private var dismiss
    @State private var password = ""
    @State private var showError = false

    let onSuccess: () -> Void
    private let correctPassword = "1"

    var body: some View {
        VStack(spacing: 20) {

            Capsule()
                .frame(width: 40, height: 5)
                .foregroundColor(.secondary.opacity(0.3))
                .padding(.top, 8)

            Text("Доступ администратора")
                .font(.title3.bold())

            SecureField("Введите пароль", text: $password)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.secondary.opacity(0.12))
                )

            if showError {
                Text("Неверный пароль")
                    .foregroundColor(.red)
            }

            Button("Войти") {
                if password == correctPassword {
                    onSuccess()
                } else {
                    withAnimation { showError = true }
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.accentColor)
            .foregroundColor(.white)
            .cornerRadius(14)

            Button("Отмена") {
                dismiss()
            }
            .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}


struct RoleButton: View {

    let title: String
    let subtitle: String
    let icon: String

    var body: some View {
        HStack(spacing: 16) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
        )
        .contentShape(Rectangle())
    }
}
