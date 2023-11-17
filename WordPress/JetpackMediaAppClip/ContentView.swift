import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject var vm = AppClipViewModel()
    @State private var showRecommended = true

    var body: some View {
        VStack {
            switch vm.appState {
            case .marketing:
                PromotionView()
                    .transition(.opacity)
            case .photosPicker(let payload):
                MediaUploadView(vm: MediaUploadViewModel(payload: payload) { success in
                    if success {
                        withAnimation(.easeInOut.delay(5.0)) {
                            vm.appState = .marketing
                        }
                    } else {
                        vm.appState = .marketing
                    }
                })
                .transition(.slide)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(gradientBackground)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
            guard let url = userActivity.webpageURL else {
                return
            }
            vm.processUrl(url)
        })
    }

    var gradientBackground: LinearGradient {
        return LinearGradient(gradient: Gradient(colors: [Color(uiColor: UIColor.green.withAlphaComponent(0.05)), .white]),
                              startPoint: .topTrailing,
                              endPoint: .bottomLeading)
    }
}
