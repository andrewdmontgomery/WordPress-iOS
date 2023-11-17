import SwiftUI
import PhotosUI

@MainActor
class MediaUploadViewModel: ObservableObject {
    @Published var viewState: MediaUploadViewState = .presented
    @Published var isMediaPickerPresented = true {
        didSet {
            if !isMediaPickerPresented && viewState == .presented {
                completion(false)
            }
        }
    }
    private let completion: (Bool) -> ()
    private let payload: MediaPayload

    init(payload: MediaPayload, completion: @escaping (Bool) -> ()) {
        self.payload = payload
        self.completion = completion
    }

    @Published var imageSelection: [PhotosPickerItem] = [] {
        didSet {
            uploadSelectedPhotos(imageSelection)
        }
    }

    private func uploadSelectedPhotos(_ photos: [PhotosPickerItem]) {
        guard !photos.isEmpty else {
            return
        }

        viewState = .uploading

        Task {
            do {
                try await withThrowingTaskGroup(of: Void.self) { [weak self] group in
                    guard let self else { return }
                    for photo in photos {
                        group.addTask {
                            try await self.uploadPhoto(photo)
                        }
                    }

                    for try await _ in group {
                        print("Image uploaded")
                    }
                }
                viewState = .success
                completion(true)
            } catch {
                print("Upload failed: \(error)")
                viewState = .failed
            }
        }
    }

    func retryUpload() {
        uploadSelectedPhotos(imageSelection)
    }

    private func uploadPhoto(_ photo: PhotosPickerItem) async throws {
        guard let req = payload.createUploadRequest() else {
            throw ImageUploadError.createRequestFailed
        }

        guard let photoData = try await photo.loadTransferable(type: Data.self) else {
            throw ImageUploadError.emptyPhotoData
        }

        guard let uiImageData = UIImage(data: photoData)?.jpegData(compressionQuality: 80) else {
            throw ImageUploadError.dataConversionFailed
        }

        let (_, response) = try await URLSession.shared.upload(for: req, from: uiImageData)

        guard
            let httpResponse = response as? HTTPURLResponse,
            200 ..< 300 ~= httpResponse.statusCode
        else {
            throw ImageUploadError.badResponse
        }
    }
}
