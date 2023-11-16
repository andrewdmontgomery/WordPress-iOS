import SwiftUI
import PhotosUI

@MainActor
class MediaUploadViewModel: ObservableObject {
    @Published var viewState: MediaUploadViewState = .presented
    @State var isMediaPickerPresented = true {
        didSet {
            if !isMediaPickerPresented && viewState == .presented {
                completion()
            }
        }
    }
    private let completion: () -> ()
    private let payload: DataPayload

    init(payload: DataPayload, completion: @escaping () -> ()) {
        self.payload = payload
        self.completion = completion
    }

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let image = imageSelection else {
                print("No image selected.")
                return
            }

            viewState = .uploading

            image.loadTransferable(type: Image.self) { [weak self] result in
                guard let self else { return }

                switch result {
                case .success(let image?):
                    DispatchQueue.main.async {
                        let renderer = ImageRenderer(content: image)
                        let uiImage = renderer.uiImage
                        guard let data = uiImage?.jpegData(compressionQuality: 80) else {
                            print("Failed to get JPEG data.")
                            return
                        }
                        self.uploadPhoto(photoData: data)
                    }
                case .success(nil):
                    viewState = .success
                    completion()
                    print("Got empty value instead of expected image.")
                case .failure(let error):
                    viewState = .failed
                    print("Error loading image: \(error)")
                }
            }
        }
    }

    func uploadPhoto(photoData: Data) {
        guard let req = payload.createUploadRequest() else {
            print("Failed to create upload request")
            return
        }

        URLSession.shared.uploadTask(with: req, from: photoData).resume()
    }
}
