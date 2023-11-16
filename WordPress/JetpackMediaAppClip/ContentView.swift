import SwiftUI
import StoreKit

struct ContentView: View {
    @StateObject var vm = AppClipViewModel()
    @State private var showRecommended = true

    var body: some View {
        VStack {
            switch vm.appState {
            case .marketing:
                Text("Marketing view")
            case .photosPicker(let payload):
                MediaUploadView(vm: MediaUploadViewModel(payload: payload) {
                    withAnimation(.easeInOut(duration: 1).delay(5)) {
                        vm.appState = .marketing
                    }
                })
            }
        }
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: { userActivity in
            // grab the payload from the URL that loaded the App Clip
            guard let url = userActivity.webpageURL else {
                return
            }
            vm.processUrl(url)
        })
        .padding()
    }
}
