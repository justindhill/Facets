//
//  NSDate+OZLExtensions.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

extension NSDate {
    func inSystemTimeZone() -> NSDate {
        let tzOffset: NSTimeInterval = Double(NSTimeZone.systemTimeZone().secondsFromGMT)
        return NSDate(timeIntervalSince1970: self.timeIntervalSince1970 - tzOffset)
    }
}
