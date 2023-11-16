//
//  AppClipViewModel.swift
//  JetpackMediaAppClip
//
//  Created by Tanner W. Stokes on 11/16/23.
//  Copyright © 2023 WordPress. All rights reserved.
//

import Foundation

@MainActor
class AppClipViewModel: ObservableObject {
    @Published var appState: AppClipState = .marketing

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

        appState = .photosPicker(jsonData)
    }
}
