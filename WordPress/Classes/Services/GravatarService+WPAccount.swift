import Gravatar

extension GravatarService {
    func uploadImage(
        _ image: UIImage,
        forAccount account: WPAccount,
        completion: ((NSError?) -> ())? = nil
    ) {
        guard let email = account.email,
              let authToken = account.authToken else {
            completion?(GravatarServiceError.invalidAccountInfo as NSError)
            return
        }

        let gravatar = GravatarService()
        gravatar.uploadImage(image, accountEmail: email, accountToken: authToken, completion: completion)
    }
}
