//
//  File.swift
//  
//
//  Created by Pinar Olguc on 18.01.2024.
//

import Foundation
import UIKit

public enum GravatarRequestError {
    
    /// The url is empty. Code 1000.
    case emptyURL
    
    /// The request is empty. Code 1001.
    case emptyRequest
    
    /// The URL of request is invalid. Code 1002.
    /// - request: The request is tend to be sent but its URL is invalid.
    case invalidURL(request: URLRequest)
    
    /// The downloading task is cancelled by user. Code 1003.
    case taskCancelled
}

public enum GravatarResponseError {
    
    /// The response is not a valid URL response. Code 2001.
    case invalidURLResponse(response: URLResponse)
    
    /// The response contains an invalid HTTP status code. Code 2002.
    /// - Note:
    ///   By default, status code 200..<400 is recognized as valid.
    case invalidHTTPStatusCode(response: HTTPURLResponse)
    
    /// An error happens in the system URL session. Code 2003.
    case URLSessionError(error: Error)
    
    /// Data modifying fails on returning a valid data. Code 2004.
    case dataModifyingFailed
    
    /// The task is done but no URL response found. Code 2005.
    case noURLResponse

    /// The task is cancelled.
    case cancelled
}

public enum GravatarError: Error {
    case requestError(reason: GravatarRequestError)
    case responseError(reason: GravatarResponseError)
}
