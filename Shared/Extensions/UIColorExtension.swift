//
//  UIColorExtension.swift
//  homeflix
//
//  Created by Martin Púčik on 22/01/2020.
//  Copyright © 2020 MartinPucik. All rights reserved.
//

import UIKit

extension UIColor {
    var hexString: String {
        let colorSpace = self.cgColor.colorSpace?.model
        let components = self.cgColor.components

        var r, g, b: CGFloat!

        if (colorSpace == .monochrome) {
            r = components?[0]
            g = components?[0]
            b = components?[0]
        } else if (colorSpace == .rgb) {
            r = components?[0]
            g = components?[1]
            b = components?[2]
        }

        return NSString(format: "#%02lX%02lX%02lX", lroundf(Float(r) * 255), lroundf(Float(g) * 255), lroundf(Float(b) * 255)) as String
    }

    var hexInt: UInt32 {
        var rgb: UInt32 = 0
        let s = Scanner(string: hexString)
        s.scanLocation = 1
        s.scanHexInt32(&rgb)
        return rgb
    }
}
