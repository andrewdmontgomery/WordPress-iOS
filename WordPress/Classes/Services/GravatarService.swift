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
        let account = GravatarValidatedAccount.account(email: account.email, authToken: account.authToken)

        switch account {
        case .invalid(let error):
            completion?(error as NSError)
        case .valid(let account):
            let gravatar = GravatarService()
            gravatar.uploadImage(image, gravatarAccount: account) { error in
                if let theError = error {
                    DDLogError("GravatarService.uploadImage Error: \(theError)")
                } else {
                    DDLogInfo("GravatarService.uploadImage Success!")
                }

                completion?(error)
            }
        }
    }
}
