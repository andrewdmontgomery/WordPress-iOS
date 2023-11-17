import SwiftUI
import Lottie

struct PromotionView: View {
    var body: some View {
        VStack(spacing: 24) {
            LottieAnimationView(name: "JetpackWordPressLogoAnimation_rtl")
                .frame(width: 50, height: 50)
            Text("Get the Jetpack Mobile App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Take your WordPress site on the go")
        }
    }
}

#Preview {
    PromotionView()
}

struct LottieAnimationView: UIViewRepresentable {
    let name: String

    func makeUIView(context: UIViewRepresentableContext<LottieAnimationView>) -> AnimationView {
        let animationView = AnimationView()
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        // TODO: Delay in another place
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            animationView.play()
        }
        return animationView
    }

    func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<LottieAnimationView>) {}
}
