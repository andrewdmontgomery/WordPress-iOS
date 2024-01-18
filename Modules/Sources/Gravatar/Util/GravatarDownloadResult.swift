//
//  GravatarDownloadResult.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public typealias GravatarDownloadProgressBlock = ((_ receivedSize: Int64, _ totalSize: Int64) -> Void)

/// Represents the result of a  Gravatar image download task.
public struct GravatarImageDownloadResult {
    /// Gets the image of this result.
    public let image: UIImage

    /// The `URL` which this result is related to.
    public let sourceURL: URL
    
    /// Gets the data behind the result.
    ///
    /// - Note:
    /// This can be a time-consuming action, so if you need to use the data for multiple times, it is suggested to hold
    /// it and prevent keeping calling this too frequently.
    // public let data: () -> Data?
}
