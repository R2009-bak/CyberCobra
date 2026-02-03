import SwiftUI
import Lottie

struct RobotLottieView: UIViewRepresentable {

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = .clear

        // ✅ правильная загрузка для Lottie 4+
        let animation = LottieAnimation.named("coder_coding")
        let animationView = LottieAnimationView(animation: animation)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.8
        animationView.contentMode = .scaleAspectFit

        animationView.play()

        containerView.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            animationView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            animationView.topAnchor.constraint(equalTo: containerView.topAnchor),
            animationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
