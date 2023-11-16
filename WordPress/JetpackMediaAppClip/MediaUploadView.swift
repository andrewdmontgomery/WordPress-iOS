import SwiftUI
import PhotosUI

struct MediaUploadView: View {
    @ObservedObject var vm: PickerModel
    @State var isPresented = true

    var body: some View {
        Text("Media Picker")
    }
}
