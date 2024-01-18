//
//  GravatarImageProcessor.swift
//
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public enum GravatarImageProcessItem {
    
    /// Input image.
    case image(UIImage)
    
    /// Input data.
    case data(Data)
}

public protocol GravatarImageProcessor {
    func process(_ item: GravatarImageProcessItem, options: GravatarDownloadOptions) -> UIImage
}
