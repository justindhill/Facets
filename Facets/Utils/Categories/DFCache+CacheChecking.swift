//
//  DFCache+CacheChecking.swift
//  Facets
//
//  Created by Justin Hill on 5/22/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import DFCache

extension DFCache {
    func isValueCachedForKey(key: String) -> Bool {
        if self.memoryCache?.valueForKey(key) != nil {
            return true
        } else if let path = self.diskCache?.pathForKey(key) {
            if NSFileManager.defaultManager().fileExistsAtPath(path) {
                return true
            }
        }

        return false
    }

    func urlForCacheKey(key: String) -> NSURL? {
        if self.isValueCachedForKey(key) {
            return self.diskCache?.URLForKey(key)
        }

        return nil
    }
}
