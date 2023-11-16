import SwiftUI
import PhotosUI

struct MediaUploadView: View {
    @ObservedObject var vm: MediaUploadViewModel

    var body: some View {
        switch vm.viewState {
        case .presented:
            Text("")
                .photosPicker(isPresented: $vm.isMediaPickerPresented, selection: $vm.imageSelection, matching: .images)
        case .uploading:
            Text("Uploading")
        case .success:
            Text("Success")
        case .failed:
            Text("Failed")
        }
    }
}
