//
//  DFCache+CacheChecking.swift
//  Facets
//
//  Created by Justin Hill on 5/22/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import DFCache

extension DFCache {
    func isValueCachedForKey(_ key: String) -> Bool {
        if self.memoryCache?.value(forKey: key) != nil {
            return true
        } else if let path = self.diskCache?.path(forKey: key) {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        return false
    }

    func urlForCacheKey(_ key: String) -> URL? {
        if self.isValueCachedForKey(key) {
            return self.diskCache?.url(forKey: key)
        }

        return nil
    }
}
