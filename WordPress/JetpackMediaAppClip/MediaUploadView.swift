import SwiftUI
import PhotosUI

struct MediaUploadView: View {
    @ObservedObject var vm: MediaUploadViewModel
    @State var isPresented = true

    var body: some View {
        switch vm.viewState {
        case .presented:
            Text("")
                .photosPicker(isPresented: $isPresented, selection: $vm.imageSelection, matching: .images)
        case .uploading:
            Text("Uploading")
        case .success:
            Text("Success")
        case .failed:
            Text("Failed")
        }
    }
}
