import SwiftUI
import Lottie
import StoreKit

struct PromotionView: View {
    @State private var isAppStoreOverlayPresented: Bool = false
    private let animationView: AnimationView = {
        let animationView = AnimationView()
        let animation = Animation.named("JetpackWordPressLogoAnimation_rtl")
        animationView.animation = animation
        return animationView
    }()
    @State private var bottomPadding: CGFloat = 0

    var body: some View {
        VStack(spacing: 24) {
            LottieAnimationView(animationView: animationView)
                .frame(width: 50, height: 50)
            Text("Get the Jetpack Mobile App")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            Text("Take your WordPress site on the go")
        }
        .padding(.bottom, bottomPadding)
       .appStoreOverlay(isPresented: $isAppStoreOverlayPresented, configuration: {
            SKOverlay.AppConfiguration(appIdentifier: "1565481562", position: .bottom)
        })
       .onAppear {
           DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               isAppStoreOverlayPresented = true
               animationView.play()
               
               withAnimation {
                   bottomPadding = 108
               }
           }
       }
    }
}

#Preview {
    PromotionView()
}

struct LottieAnimationView: UIViewRepresentable {
    let animationView: Lottie.AnimationView

    func makeUIView(context: UIViewRepresentableContext<LottieAnimationView>) -> AnimationView {
        animationView.contentMode = .scaleAspectFit
        return animationView
    }

    func updateUIView(_ uiView: AnimationView, context: UIViewRepresentableContext<LottieAnimationView>) {}
}
