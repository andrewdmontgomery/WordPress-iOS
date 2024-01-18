//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public enum ImageTransition {
    /// No animation transition.
    case none
    /// Fade in the loaded image in a given duration.
    case fade(TimeInterval)
}

public enum GravatarDownloadOption {
    // The value is used when converting the retrieved data to an image.
    // Default value is: UIScreen.main.scale. You may set values as `1.0`, `2.0`, `3.0`.
    case scaleFactor(CGFloat)
    
    // Gravatar Image Ratings. Defaults to: GravatarRatings.default.
    case gravatarRating(GravatarRatings)
    
    // Transition style to use when setting the new image downloaded. Default: .fade(0.3)
    case transition(ImageTransition)
        
    // Preferred size of the image that will be downloaded. If not provided, layoutIfNeeded() is called on the view to get its bounds properly.
    // You can pass the preferred size to avoid the layoutIfNeeded() call and get a performance benefit.
    case preferredSize(CGSize)
    
    // By setting this option, the placeholder will be ignored and the current image will be kept while downloading the new image.
    case keepCurrentImageWhileLoading
}

// Parsed download options
public struct GravatarDownloadOptions {
    static let defaultSize: CGSize = .init(width: 80, height: 80)
    
    var scaleFactor: CGFloat = UIScreen.main.scale
    var gravatarRating: GravatarRatings = .default
    var transition: ImageTransition = .fade(0.3)
    var preferredSize: CGSize? = nil
    var keepCurrentImageWhileLoading = false

    init(options: [GravatarDownloadOption]?) {
        guard let options = options else { return }
        for option in options {
            switch option {
            case .gravatarRating(let rating):
                gravatarRating = rating
            case .scaleFactor(let scale):
                scaleFactor = scale
            case .transition(let imageTransition):
                transition = imageTransition
            case .preferredSize(let size):
                preferredSize = size
            case .keepCurrentImageWhileLoading:
                keepCurrentImageWhileLoading = true
            }
        }
    }
}
