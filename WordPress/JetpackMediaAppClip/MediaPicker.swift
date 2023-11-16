import SwiftUI
import PhotosUI

struct MediaPicker: View {
    @ObservedObject var vm: PickerModel
    @State var isPresented = true

    var body: some View {
        Button("Select a photo") {
            isPresented = true
            vm.imageSelection = nil
        }
            .photosPicker(isPresented: $isPresented, selection: $vm.imageSelection, matching: .images)
    }
}
