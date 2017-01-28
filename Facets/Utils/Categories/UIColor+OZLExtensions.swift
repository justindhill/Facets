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
    @objc func circularImageWithDiameter(_ diameter: CGFloat) -> UIImage {
        let containingRect = CGRect(x: 0, y: 0, width: diameter, height: diameter)

        UIGraphicsBeginImageContextWithOptions(containingRect.size, false, 0)
        let ctx = UIGraphicsGetCurrentContext()

        self.setFill()
        ctx?.fillEllipse(in: containingRect)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return image!
    }
}
