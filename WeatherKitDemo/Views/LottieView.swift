import Lottie
import SwiftUI

struct LottieView: UIViewRepresentable {
    let animationView: LottieAnimationView
    let contentMode: UIView.ContentMode
    let name: String // of the animation
    let loopMode: LottieLoopMode
    @Binding var play: Bool
    let speed: CGFloat

    init(
        name: String,
        loopMode: LottieLoopMode = .playOnce,
        speed: CGFloat = 1,
        contentMode: UIView.ContentMode = .scaleAspectFit,
        play: Binding<Bool> = .constant(true)
    ) {
        animationView = LottieAnimationView(name: name)
        self.contentMode = contentMode
        self.loopMode = loopMode
        self.name = name
        _play = play
        self.speed = speed
    }

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: .zero)
        view.addSubview(animationView)

        animationView.contentMode = contentMode
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.heightAnchor.constraint(equalTo: view.heightAnchor)
            .isActive = true
        animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
            .isActive = true
        animationView.loopMode = loopMode
        animationView.animationSpeed = speed

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        if play {
            animationView.play { _ in play = false }
        }
    }
}
