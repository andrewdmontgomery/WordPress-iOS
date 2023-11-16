import Foundation

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
