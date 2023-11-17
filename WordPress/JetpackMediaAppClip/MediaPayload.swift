import Foundation

struct MediaPayload: Decodable {
    let user: String
    let pass: String
    let wpHost: String

    private var endPoint: URL? {
        URL(string: "\(wpHost)/wp-json/wp/v2/media")
    }

    private func encodeCredentials() -> String? {
        let credentialString = "\(user):\(pass)"
        let data = credentialString.data(using: .utf8)
        return data?.base64EncodedString()
    }

    func createUploadRequest() -> URLRequest? {
        guard
            let endPoint,
            let encodedCredentials = encodeCredentials()
        else {
            print("Failed to create upload request.")
            return nil
        }

        var request = URLRequest(url: endPoint)
        request.setValue("image/jpg", forHTTPHeaderField: "Content-Type")
        request.setValue("attachment; filename=image.jpg", forHTTPHeaderField: "Content-Disposition")
        request.setValue("Basic \(encodedCredentials)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "POST"

        return request
    }
}
