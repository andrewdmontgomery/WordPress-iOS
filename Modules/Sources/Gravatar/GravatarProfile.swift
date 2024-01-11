//
//  GravatarProfile.swift
//
//
//  Created by Andrew Montgomery on 1/10/24.
//

public enum GravatarProfileResult {
    case success(GravatarProfile)
    case failure(GravatarServiceError)
}

public struct GravatarProfile {

    var profileID = ""
    var hash = ""
    var requestHash = ""
    var profileUrl = ""
    var preferredUsername = ""
    var thumbnailUrl = ""
    var name = ""
    var displayName = ""

}
