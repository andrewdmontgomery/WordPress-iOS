import SwiftUI

struct ContentView: View {
    @StateObject var vm = PickerModel()

    var body: some View {
        VStack {
            MediaPicker(vm: vm)
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
