import Foundation

@MainActor
class AppClipViewModel: ObservableObject {
    @Published var appState: AppClipState = .marketing

    var payload: MediaPayload? {
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
        guard let jsonData = try? jsonDecoder.decode(MediaPayload.self, from: data) else {
            print("Couldn't decode URL payload.")
            return
        }

        appState = .photosPicker(jsonData)
    }
}
