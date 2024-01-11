import Foundation
import CocoaLumberjack
import WordPressKit
import Gravatar


/// This Service exposes all of the valid operations we can execute, to interact with the Gravatar Service.
///
open class WPGravatarService {

    /// This method fetches the Gravatar profile for the specified email address.
    ///
    /// - Parameters:
    ///     - email: The email address of the gravatar profile to fetch.
    ///     - completion: A completion block.
    ///
    open func fetchProfile(email: String, onCompletion: @escaping ((_ profile: GravatarProfile?) -> Void)) {
        let gravatar = GravatarService()

        gravatar.fetchProfile(email: email) { result in
            switch result {
            case .success(let profile):
                onCompletion(profile)
            case .failure(let error):
                DDLogError(error.debugDescription)
                onCompletion(nil)
            }
        }
    }


    /// This method hits the Gravatar Endpoint, and uploads a new image, to be used as profile.
    ///
    /// - Parameters:
    ///     - image: The new Gravatar Image, to be uploaded
    ///     - account: The WPAccount instance for which to upload a new image.
    ///     - completion: An optional closure to be executed on completion.
    ///
    open func uploadImage(_ image: UIImage, forAccount account: WPAccount, completion: ((_ error: NSError?) -> ())? = nil) {
        guard
            let accountToken = account.authToken, !accountToken.isEmpty,
            let accountEmail = account.email, !accountEmail.isEmpty else {
                completion?(GravatarServiceError.invalidAccountInfo as NSError)
                return
        }

        let email = accountEmail.trimmingCharacters(in: CharacterSet.whitespaces).lowercased()

        let remote = gravatarServiceRemote()
        remote.uploadImage(image, accountEmail: email, accountToken: accountToken) { (error) in
            if let theError = error {
                DDLogError("GravatarService.uploadImage Error: \(theError)")
            } else {
                DDLogInfo("GravatarService.uploadImage Success!")
            }

            completion?(error)
        }
    }

    /// Overridden by tests for mocking.
    ///
    func gravatarServiceRemote() -> GravatarServiceRemote {
        return GravatarServiceRemote()
    }
}
