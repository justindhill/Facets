//
//  OZLAsyncImageView.swift
//  Facets
//
//  Created by Justin Hill on 11/26/15.
//  Copyright © 2015 Justin Hill. All rights reserved.
//

import UIKit

class OZLAsyncImageView: UIImageView {
    
    var request: SDWebImageOperation?
    
    var url: NSURL? = nil {
        willSet(newURL) {
            self.cancelExistingImageRequest()
        }
        
        didSet {
            self.image = nil
            
            if let url = self.url {
                self.startRequestForImageAtURL(url)
            }
        }
    }
    
    private func startRequestForImageAtURL(url: NSURL) {
        weak var weakSelf = self
        
        SDWebImageManager.sharedManager().downloadImageWithURL(url, options: SDWebImageOptions(rawValue: 0), progress: nil) { (image, error, cacheType, finished, url) -> Void in
            if url === self.url, let image = image, let weakSelf = weakSelf {
                UIView.transitionWithView(weakSelf, duration: 0.25, options: .TransitionCrossDissolve, animations: { () -> Void in
                    weakSelf.image = image
                }, completion: nil)
            }
        }
    }
    
    private func cancelExistingImageRequest() {
        if let request = self.request {
            request.cancel()
        }
    }
}
