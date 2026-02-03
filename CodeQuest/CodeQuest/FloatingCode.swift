import SwiftUI

struct FloatingCode: View {

    let codeLines = [
        #"while count < n:"#,
        #"for i in range(5):"#,
        #"if x > 0:"#,
        #"print ("Hello");"#,
        #"Console.WriteLine("Hi");"#
    ]

    @State private var index = 0
    @State private var float = false

    var body: some View {
        Text(codeLines[index])
            .font(.system(size: 15, weight: .medium, design: .monospaced))
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        Color.purple.opacity(0.9),
                        Color.blue.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .offset(y: float ? -6 : 6)
            .animation(
                .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: true),
                value: float
            )
            .transition(.opacity)
            .id(index)
            .onAppear {
                float = true
                startAnimation()
            }
    }

    private func startAnimation() {
        Timer.scheduledTimer(withTimeInterval: 2.8, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.6)) {
                index = (index + 1) % codeLines.count
            }
        }
    }
}
