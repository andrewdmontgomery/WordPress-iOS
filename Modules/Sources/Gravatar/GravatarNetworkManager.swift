//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation

public class GravatarNetworkManager {
    
    var imageCache: GravatarImageCaching
    private let processingQueue: DispatchQueue

    init(imageCache: GravatarImageCaching) {
        self.imageCache = imageCache
        let processQueueName = "com.Gravatar.processQueue.\(UUID().uuidString)"
        processingQueue = DispatchQueue(label: processQueueName)
    }
    
    convenience init() {
        self.init(imageCache: GravatarImageCache.shared)
    }
    
    @discardableResult
    public func retrieveImage(
        with url: URL,
        options: GravatarDownloadOptions? = nil,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil) -> URLSessionDataTask? {
            //TODO:
            return nil
        }
}
