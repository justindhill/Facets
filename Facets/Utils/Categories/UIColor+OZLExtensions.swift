//
//  UIColor+OZLExtensions.swift
//  Facets
//
//  Created by Justin Hill on 4/30/16.
//  Copyright © 2016 Justin Hill. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

extension UIColor {
    @objc func circularImageWithDiameter(diameter: CGFloat) -> UIImage {
        let containingRect = CGRectMake(0, 0, diameter, diameter)

        UIGraphicsBeginImageContextWithOptions(containingRect.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        self.setFill()
        CGContextFillEllipseInRect(ctx, containingRect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image
    }
}