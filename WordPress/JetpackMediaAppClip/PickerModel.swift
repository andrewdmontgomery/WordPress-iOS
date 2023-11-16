import SwiftUI
import PhotosUI

@MainActor
class PickerModel: ObservableObject {
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

    var payload: DataPayload? {
        didSet {
            if let payload {
                print("Payload data from URL successfully set.")
                print(payload)
            }
        }
    }

    func processUrl(_ url: URL) {
        print("URL to process: \(url)")
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("Couldn't get URL components.")
            return
        }

        guard
            let firstParam = components.queryItems?.first,
            firstParam.name == "data",
            let encodedData = firstParam.value?.data(using: .utf8),
            let data = Data(base64Encoded: encodedData)
        else {
            print("Didn't get expected data parameter.")
            return
        }

        let jsonDecoder = JSONDecoder()
        guard let jsonData = try? jsonDecoder.decode(DataPayload.self, from: data) else {
            print("Couldn't decode URL payload.")
            return
        }

        payload = jsonData
    }

    func uploadPhoto(photoData: Data) {
        guard let payload else {
            print("No server info to upload the photo with!")
            return
        }

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
