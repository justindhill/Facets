//
//  OZLAttachmentManager.swift
//  Facets
//
//  Created by Justin Hill on 5/14/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation
import DFCache

@objc enum OZLAttachmentManagerError: Int {
    case InvalidOrMissingContentURL
    case UnacceptableStatusCode
}

@objc class OZLAttachmentManager: NSObject, NSURLSessionDownloadDelegate {
    static let ErrorDomain = "OZLAttachmentManagerErrorDomain"

    private static let CacheIdentifier = "facets.attachments"
    private let cache = DFCache(name: OZLAttachmentManager.CacheIdentifier, memoryCache: nil)
    private let networkManager: OZLNetwork

    // key: taskIdentifier, value: (attachment, progressHandler, completionHandler)
    private var taskAssociations: [Int: (OZLModelAttachment, ((attachment: OZLModelAttachment, bytesDownloaded: Int64, totalBytesExpected: Int64) -> Void)?, (data: NSData?, error: NSError?) -> Void)] = [:]

    private lazy var urlSession: () -> NSURLSession = {
        return NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: nil)
    }

    init(networkManager: OZLNetwork) {
        self.networkManager = networkManager
        super.init()
    }


    func isAttachmentCached(attachment: OZLModelAttachment) -> Bool {
        return self.cache.isValueCachedForKey(attachment.cacheKey)
    }

    func downloadAttachment(
        attachment: OZLModelAttachment,
        progress: ((attachment: OZLModelAttachment, totalBytesDownloaded: Int64, totalBytesExpected: Int64) -> Void)?,
        completion: (data: NSData?, error: NSError?) -> Void) {

        if let cachedData = self.cache.cachedDataForKey(attachment.cacheKey) {
            dispatch_async(dispatch_get_main_queue(), { 
                completion(data: cachedData, error: nil)
            })

            return
        }

        guard let contentUrl = NSURL(string: attachment.contentURL) else {
            dispatch_async(dispatch_get_main_queue(), { 
                completion(
                    data: nil,
                    error: NSError(
                        domain: OZLAttachmentManager.ErrorDomain,
                        code: OZLAttachmentManagerError.InvalidOrMissingContentURL.rawValue,
                        userInfo: [
                            NSLocalizedDescriptionKey: "The attachment's content URL was missing or invalid."
                        ]
                    )
                )
            })

            return
        }

        let downloadTask = self.urlSession().downloadTaskWithURL(contentUrl)

        self.taskAssociations[downloadTask.taskIdentifier] = (attachment, progress, completion)
        self.networkManager.activeRequestCount += 1

        downloadTask.resume()
    }

    func fetchURLForLocalAttachment(attachment: OZLModelAttachment) -> NSURL? {
        return self.cache.diskCache?.URLForKey(attachment.cacheKey)
    }

    func fetchLocalAttachment(attachment: OZLModelAttachment) -> NSData? {
        return self.cache.cachedDataForKey(attachment.cacheKey)
    }

    func fetchLocalAttachment(attachment: OZLModelAttachment, completion: (data: NSData?) -> Void) {
        self.cache.cachedDataForKey(String(attachment.cacheKey)) { (data) in
            dispatch_async(dispatch_get_main_queue(), {
                completion(data: data)
            })
        }
    }

    // NSURLSessionDelegate
    func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
        guard let (_, _, completion) = self.taskAssociations[task.taskIdentifier] else {
            return
        }

        defer {
            self.networkManager.activeRequestCount -= 1
            self.taskAssociations.removeValueForKey(task.taskIdentifier)
        }

        if let error = error {
            dispatch_async(dispatch_get_main_queue(), {
                completion(data: nil, error: error)
            })

            return
        }

        guard let r = task.response as? NSHTTPURLResponse where 200..<300 ~= r.statusCode else {
            let error = NSError(
                domain: OZLAttachmentManager.ErrorDomain,
                code: OZLAttachmentManagerError.UnacceptableStatusCode.rawValue,
                userInfo: [ NSLocalizedDescriptionKey: "Expected a status code between 200 and 300. Response: \(task.response)"]
            )

            dispatch_async(dispatch_get_main_queue(), {
                completion(data: nil, error: error)
            })

            return
        }
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
        guard let (attachment, _, completion) = self.taskAssociations[downloadTask.taskIdentifier] else {
            return
        }

        if let data = NSData(contentsOfURL: location) {
            self.cache.storeData(data, forKey: attachment.cacheKey)

            dispatch_async(dispatch_get_main_queue(), {
                completion(data: data, error: nil)
            })

            self.networkManager.activeRequestCount -= 1
            self.taskAssociations.removeValueForKey(downloadTask.taskIdentifier)
        }
    }

    func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if let (attachment, progressHandler, _) = self.taskAssociations[downloadTask.taskIdentifier] {
            dispatch_async(dispatch_get_main_queue(), {
                progressHandler?(attachment: attachment, bytesDownloaded: totalBytesWritten, totalBytesExpected: totalBytesExpectedToWrite)
            })
        }
    }
}
