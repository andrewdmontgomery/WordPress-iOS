
import Foundation

extension Media {

    @objc(updateWithRemoteMedia:)
    func update(with remoteMedia: RemoteMedia) {
        if mediaID != remoteMedia.mediaID {
            mediaID =  remoteMedia.mediaID
        }
        if remoteURL != remoteMedia.url?.absoluteString {
            remoteURL = remoteMedia.url?.absoluteString
        }
        if remoteLargeURL != remoteMedia.largeURL?.absoluteString {
            remoteLargeURL = remoteMedia.largeURL?.absoluteString
        }
        if remoteMediumURL != remoteMedia.mediumURL?.absoluteString {
            remoteMediumURL = remoteMedia.mediumURL?.absoluteString
        }
        if remoteMedia.date != nil && remoteMedia.date != creationDate {
            creationDate = remoteMedia.date
        }
        if filename != remoteMedia.file {
            filename = remoteMedia.file
        }
        if let mimeType = remoteMedia.mimeType, !mimeType.isEmpty {
            setMediaTypeForMimeType(mimeType)
        } else if let fileExtension = remoteMedia.extension, !fileExtension.isEmpty {
            setMediaTypeForExtension(fileExtension)
        }
        if title != remoteMedia.title {
            title = remoteMedia.title
        }
        if caption != remoteMedia.caption {
            caption = remoteMedia.caption
        }
        if desc != remoteMedia.descriptionText {
            desc = remoteMedia.descriptionText
        }
        if alt != remoteMedia.alt {
            alt = remoteMedia.alt
        }
        if height != remoteMedia.height {
            height = remoteMedia.height
        }
        if width != remoteMedia.width {
            width = remoteMedia.width
        }
        if shortcode != remoteMedia.shortcode {
            shortcode = remoteMedia.shortcode
        }
        if videopressGUID != remoteMedia.videopressGUID {
            videopressGUID = remoteMedia.videopressGUID
        }
        if length != remoteMedia.length {
            length = remoteMedia.length
        }
        if remoteThumbnailURL != remoteMedia.remoteThumbnailURL {
            remoteThumbnailURL = remoteMedia.remoteThumbnailURL
        }
        if postID != remoteMedia.postID {
            postID = remoteMedia.postID
        }
        if remoteStatus != .sync {
            remoteStatus = .sync
        }
        if error != nil {
            error = nil
        }
    }

}
