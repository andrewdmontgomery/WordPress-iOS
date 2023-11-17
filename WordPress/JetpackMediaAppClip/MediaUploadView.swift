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
            MediaUploadProgressView(
                state: .loading,
                title: "Uploading media",
                description: "The images will appear on web when they are done"
            )
        case .success:
            MediaUploadProgressView(
                state: .success,
                title: "Media uploaded",
                description: "Check web to see your freshly uploaded media"
            )
        case .failed:
            MediaUploadProgressView(
                state: .failure,
                title: "Upload failed",
                description: "You couldn't send your media to web",
                buttonTitle: "Retry"
            ) {
                vm.retryUpload()
            }
        }
    }
}
