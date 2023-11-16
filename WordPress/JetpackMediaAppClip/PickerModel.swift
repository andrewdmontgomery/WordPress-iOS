import SwiftUI
import PhotosUI

@MainActor
class PickerModel: ObservableObject {
    let payload: DataPayload

    init(payload: DataPayload) {
        self.payload = payload
    }

    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            guard let image = imageSelection else {
                print("No image selected.")
                return
            }

            image.loadTransferable(type: Image.self) { result in
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
                    print("Got empty value instead of expected image.")
                case .failure(let error):
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

@MainActor
struct DataPayload: Decodable {
    let user: String
    let pass: String
    let wpHost: String

    private func getEndpoint() -> URL {
        /// NOTE: For local dev this may have to get tweaked due to the hostname.
        return URL(string: "\(wpHost)/wp-json/wp/v2/media")!
    }

    private func encodeCredentials() -> String? {
        let credentialString = "\(user):\(pass)"
        let data = credentialString.data(using: .utf8)
        return data?.base64EncodedString()
    }

    func createUploadRequest() -> URLRequest? {
        guard let encodedCredentials = encodeCredentials() else {
            print("Failed to encode credentials")
            return nil
        }

        let endPoint = getEndpoint()
        var request = URLRequest(url: endPoint)
        request.setValue("image/jpg", forHTTPHeaderField: "Content-Type")
        request.setValue("attachment; filename=image.jpg", forHTTPHeaderField: "Content-Disposition")
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        return request
    }
}
