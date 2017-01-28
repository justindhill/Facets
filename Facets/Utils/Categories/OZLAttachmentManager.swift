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
    case invalidOrMissingContentURL
    case unacceptableStatusCode
}

@objc class OZLAttachmentManager: NSObject, URLSessionDownloadDelegate {
    static let ErrorDomain = "OZLAttachmentManagerErrorDomain"

    fileprivate static let CacheIdentifier = "facets.attachments"
    fileprivate let cache = DFCache(name: OZLAttachmentManager.CacheIdentifier, memoryCache: nil)
    fileprivate let networkManager: OZLNetwork

    // key: taskIdentifier, value: (attachment, progressHandler, completionHandler)
    fileprivate var taskAssociations: [Int: (OZLModelAttachment,
                                            ((_ attachment: OZLModelAttachment, _ bytesDownloaded: Int64, _ totalBytesExpected: Int64) -> Void)?,
                                            (_ data: Data?, _ error: NSError?) -> Void)] = [:]

    fileprivate lazy var urlSession: () -> Foundation.URLSession = {
        return Foundation.URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }

    init(networkManager: OZLNetwork) {
        self.networkManager = networkManager
        super.init()
    }


    func isAttachmentCached(_ attachment: OZLModelAttachment) -> Bool {
        return self.cache.isValueCachedForKey(attachment.cacheKey)
    }

    func downloadAttachment(
        _ attachment: OZLModelAttachment,
        progress: ((_ attachment: OZLModelAttachment, _ totalBytesDownloaded: Int64, _ totalBytesExpected: Int64) -> Void)?,
        completion: @escaping (_ data: Data?, _ error: NSError?) -> Void) {

        if let cachedData = self.cache.cachedData(forKey: attachment.cacheKey) {
            DispatchQueue.main.async(execute: { 
                completion(cachedData, nil)
            })

            return
        }

        guard let contentUrl = URL(string: attachment.contentURL) else {
            DispatchQueue.main.async(execute: { 
                completion(
                    nil,
                    NSError(
                        domain: OZLAttachmentManager.ErrorDomain,
                        code: OZLAttachmentManagerError.invalidOrMissingContentURL.rawValue,
                        userInfo: [
                            NSLocalizedDescriptionKey: "The attachment's content URL was missing or invalid."
                        ]
                    )
                )
            })

            return
        }

        let downloadTask = self.urlSession().downloadTask(with: contentUrl)

        self.taskAssociations[downloadTask.taskIdentifier] = (attachment, progress, completion)
        self.networkManager.activeRequestCount += 1

        downloadTask.resume()
    }

    func fetchURLForLocalAttachment(_ attachment: OZLModelAttachment) -> URL? {
        return self.cache.diskCache?.url(forKey: attachment.cacheKey)
    }

    func fetchLocalAttachment(_ attachment: OZLModelAttachment) -> Data? {
        return self.cache.cachedData(forKey: attachment.cacheKey)
    }

    func fetchLocalAttachment(_ attachment: OZLModelAttachment, completion: @escaping (_ data: Data?) -> Void) {
        self.cache.cachedData(forKey: attachment.cacheKey) { (data) in
            dispatchMain(completion(data))
//            DispatchQueue.main.async {
//                completion(data: dataaaa)
//            }
//            DispatchQueue.main.async(execute: {
//            })
        }
//        self.cache.cachedData(forKey: "asdf", completion: { (data) in

//        })
    }

    // NSURLSessionDelegate
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let (_, _, completion) = self.taskAssociations[task.taskIdentifier] else {
            return
        }

        defer {
            self.networkManager.activeRequestCount -= 1
            self.taskAssociations.removeValue(forKey: task.taskIdentifier)
        }

        if let error = error {
            DispatchQueue.main.async(execute: {
                completion(nil, error as NSError?)
            })

            return
        }

        guard let r = task.response as? HTTPURLResponse, 200..<300 ~= r.statusCode else {
            let error = NSError(
                domain: OZLAttachmentManager.ErrorDomain,
                code: OZLAttachmentManagerError.unacceptableStatusCode.rawValue,
                userInfo: [ NSLocalizedDescriptionKey: "Expected a status code between 200 and 300. Response: \(task.response)"]
            )

            DispatchQueue.main.async(execute: {
                completion(nil, error)
            })

            return
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let (attachment, _, completion) = self.taskAssociations[downloadTask.taskIdentifier] else {
            return
        }

        if let data = try? Data(contentsOf: location) {
            self.cache.store(data, forKey: attachment.cacheKey)

            DispatchQueue.main.async(execute: {
                completion(data, nil)
            })

            self.networkManager.activeRequestCount -= 1
            self.taskAssociations.removeValue(forKey: downloadTask.taskIdentifier)
        }
    }

    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {

        if let (attachment, progressHandler, _) = self.taskAssociations[downloadTask.taskIdentifier] {
            DispatchQueue.main.async(execute: {
                progressHandler?(attachment, totalBytesWritten, totalBytesExpectedToWrite)
            })
        }
    }
}
