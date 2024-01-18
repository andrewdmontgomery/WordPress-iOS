//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public extension NSNotification.Name {
    static let GravatarUpdateNotification = NSNotification.Name(rawValue: "GravatarUpdateNotification")
}

// MARK: - Associated Object
private var taskIdentifierKey: Void?
private var indicatorKey: Void?
private var indicatorTypeKey: Void?
private var placeholderKey: Void?
private var imageTaskKey: Void?
private var notificationWrapperKey: Void?
private var dataTaskKey: Void?

extension GravatarWrapper where Component: UIImageView {
    
    /// Describes which indicator type is going to be used. Default is `.none`, which means no activity indicator will be shown.
    public var activityIndicatorType: GravatarActivityIndicatorType {
        get {
            return getAssociatedObject(component, &indicatorTypeKey) ?? .none
        }
        
        set {
            switch newValue {
            case .none: 
                activityIndicator = nil
            case .activity:
                activityIndicator = DefaultActivityIndicator()
            case .custom(let indicator):
                activityIndicator = indicator
            }
            setRetainedAssociatedObject(component, &indicatorTypeKey, newValue)
        }
    }
    
    /// The activityIndicator to show during network operations .
    public private(set) var activityIndicator: GravatarActivityIndicator? {
        get {
            let box: Box<GravatarActivityIndicator>? = getAssociatedObject(component, &indicatorKey)
            return box?.value
        }
        
        set {
            // Remove previous
            if let previousIndicator = activityIndicator {
                previousIndicator.view.removeFromSuperview()
            }
            
            // Add new
            if let newIndicator = newValue {

                let newIndicatorView = newIndicator.view
                component.addSubview(newIndicatorView)
                newIndicatorView.translatesAutoresizingMaskIntoConstraints = false
                newIndicatorView.centerXAnchor.constraint(
                    equalTo: component.centerXAnchor).isActive = true
                newIndicatorView.centerYAnchor.constraint(
                    equalTo: component.centerYAnchor).isActive = true

                switch newIndicator.sizeStrategy(in: component) {
                case .intrinsicSize:
                    break
                case .full:
                    newIndicatorView.heightAnchor.constraint(equalTo: component.heightAnchor, constant: 0).isActive = true
                    newIndicatorView.widthAnchor.constraint(equalTo: component.widthAnchor, constant: 0).isActive = true
                case .size(let size):
                    newIndicatorView.heightAnchor.constraint(equalToConstant: size.height).isActive = true
                    newIndicatorView.widthAnchor.constraint(equalToConstant: size.width).isActive = true
                }
                
                newIndicator.view.isHidden = true
            }

            setRetainedAssociatedObject(component, &indicatorKey, newValue.map(Box.init))
        }
    }
    
    /// A `Placeholder` will be shown in the imageview until the download completes.
    public private(set) var placeholder: UIImage? {
        get { return getAssociatedObject(component, &placeholderKey) }
        set {
            if let previousPlaceholder = placeholder {
                component.image = nil
            }
            
            if let newPlaceholder = newValue {
                component.image = newPlaceholder
            } else {
                component.image = nil
            }
            setRetainedAssociatedObject(component, &placeholderKey, newValue)
        }
    }
    
    private var downloadTask: URLSessionDownloadTask? {
        get {
            return getAssociatedObject(component, &dataTaskKey)
        }
        set {
            setDownloadTask(newValue)
        }
    }
    
    public private(set) var taskIdentifier: UInt? {
        get {
            let box: Box<UInt>? = getAssociatedObject(component, &taskIdentifierKey)
            return box?.value
        }
        set {
            let box = newValue.map { Box($0) }
            setRetainedAssociatedObject(component, &taskIdentifierKey, box)
        }
    }
    
    private func setDownloadTask(_ newValue: URLSessionDownloadTask?) {
        setRetainedAssociatedObject(component, &dataTaskKey, newValue)
    }
    
    private var notificationWrapper: NotificationWrapper? {
        get {
            return getAssociatedObject(component, &notificationWrapperKey)
        }
        set {
            setRetainedAssociatedObject(component, &notificationWrapperKey, newValue)
        }
    }
    
    public func listenForGravatarChanges(forEmail trackedEmail: String) {
        if let currentObersver = notificationWrapper?.observer {
            NotificationCenter.default.removeObserver(currentObersver)
            setRetainedAssociatedObject(component, &notificationWrapperKey, nil as NotificationWrapper?)
        }

        let observer = NotificationCenter.default.addObserver(forName: .GravatarUpdateNotification, object: nil, queue: nil) { [weak component] (notification) in
            guard let userInfo = notification.userInfo,
                  let email = userInfo[GravatarNotificationKey.email] as? String,
                email == trackedEmail,
                let image = userInfo[GravatarNotificationKey.image] as? UIImage else {
                    return
            }

            component?.image = image
        }
        setRetainedAssociatedObject(component, &notificationWrapperKey, NotificationWrapper(observer: observer))
    }
    
    public func cancelImageDownload() {
        downloadTask?.cancel()
        setDownloadTask(nil)
    }
    
    @discardableResult
    public func setImage(
        email: String,
        placeholder: UIImage? = nil,
        options: [GravatarDownloadOption]? = nil,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil) -> URLSessionDataTask?
    {
        let options = GravatarDownloadOptions(options: options)
        let gravatarURL = Gravatar.gravatarUrl(for: email, size: gravatarDefaultSize(preferredSize: options.preferredSize), rating: options.gravatarRating)

        return setImage(with: gravatarURL, placeholder: placeholder, parsedOptions: options, completionHandler: completionHandler)
    }

    public func setImage(
        with source: URL?,
        placeholder: UIImage? = nil,
        parsedOptions: GravatarDownloadOptions,
        completionHandler: ((Result<GravatarImageDownloadResult, GravatarError>) -> Void)? = nil) -> URLSessionDataTask?
    {
        var mutatingSelf = self
        guard let source = source else {
            mutatingSelf.placeholder = placeholder
            mutatingSelf.taskIdentifier = nil
            completionHandler?(.failure(GravatarError.requestError(reason: .emptyURL)))
            return nil
        }
        
        var options = parsedOptions
        
        let isEmptyImage = component.image == nil && self.placeholder == nil
        if !options.keepCurrentImageWhileLoading || isEmptyImage {
            // Always set placeholder while there is no image/placeholder yet.
            mutatingSelf.placeholder = placeholder
        }
        
        activityIndicator?.startAnimatingView()
        
        let issuedIdentifier = TaskCounter.next()
        mutatingSelf.taskIdentifier = issuedIdentifier
        
        // TODO: Network call to download the image
        return nil
    }
    
    
    private func gravatarDefaultSize(preferredSize: CGSize?) -> Int {
        var size = GravatarDownloadOptions.defaultSize
        if let preferredSize {
            size = preferredSize
        }
        else {
            component.layoutIfNeeded()
            if component.bounds.size.equalTo(.zero) == false {
                size = component.bounds.size
            }
        }

        let targetSize = max(size.width, size.height) * UIScreen.main.scale
        return Int(targetSize)
    }

}
