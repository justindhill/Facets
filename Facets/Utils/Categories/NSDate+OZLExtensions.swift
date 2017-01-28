//
//  NSDate+OZLExtensions.swift
//  Facets
//
//  Created by Justin Hill on 3/13/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

extension Date {
    func inSystemTimeZone() -> Date {
        let tzOffset: TimeInterval = Double(NSTimeZone.system.secondsFromGMT())
        return Date(timeIntervalSince1970: self.timeIntervalSince1970 - tzOffset)
    }
}
