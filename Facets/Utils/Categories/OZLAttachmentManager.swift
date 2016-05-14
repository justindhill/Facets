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

@objc class OZLAttachmentManager: NSObject {
    static let ErrorDomain = "OZLAttachmentManagerErrorDomain"

    private static let CacheIdentifier = "facets.attachments"
    private let cache = DFCache(name: OZLAttachmentManager.CacheIdentifier, memoryCache: nil)
    private let networkManager: OZLNetwork

    init(networkManager: OZLNetwork) {
        self.networkManager = networkManager
        super.init()
    }

    func isAttachmentCached(attachment: OZLModelAttachment) -> Bool {
        return self.cache.metadataForKey(String(attachment.attachmentID)) != nil
    }

    func downloadAttachment(attachment: OZLModelAttachment, completion: (data: NSData?, error: NSError?) -> Void) {
        if let cachedData = self.cache.cachedDataForKey(String(attachment.attachmentID)) {
            dispatch_async(dispatch_get_main_queue(), { 
                completion(data: cachedData, error: nil)
            })

            return
        }

        guard let contentUrl = NSURL(string: attachment.contentURL) else {
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

            return
        }

        let downloadTask = self.networkManager.urlSession.downloadTaskWithURL(contentUrl) { (fileUrl, response, error) in
            guard let fileUrl = fileUrl else {
                completion(data: nil, error: error)
                return
            }

            guard let r = response as? NSHTTPURLResponse where 200..<300 ~= r.statusCode else {
                let error = NSError(
                    domain: OZLAttachmentManager.ErrorDomain,
                    code: OZLAttachmentManagerError.UnacceptableStatusCode.rawValue,
                    userInfo: [ NSLocalizedDescriptionKey: "Expected a status code between 200 and 300. Response: \(response)"]
                )

                completion(data: nil, error: error)
                return
            }

            guard let data = NSData(contentsOfURL: fileUrl) else {
                completion(data: nil, error: nil)
                return
            }

            completion(data: data, error: nil)
        }

        downloadTask.resume()
    }

    func fetchLocalAttachmentWithId(attachmentId: Int, completion: (data: NSData?) -> Void) {
        self.cache.cachedDataForKey(String(attachmentId)) { (data) in
            completion(data: data)
        }
    }
}
