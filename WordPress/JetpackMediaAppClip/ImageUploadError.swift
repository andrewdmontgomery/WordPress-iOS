import Foundation

enum ImageUploadError: Error {
    case createRequestFailed
    case dataConversionFailed
    case emptyPhotoData
    case badResponse
}
