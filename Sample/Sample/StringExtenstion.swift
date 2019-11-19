//
//  StringExtenstion.swift
//  
//
//  Created by Tae Hyun Na on 2017. 1. 15.
//  Copyright (c) 2014, P9 SOFT, Inc. All rights reserved.
//
//  Licensed under the MIT license.

import UIKit

extension String {
    
    var colorByHex: UIColor {
        var rgbPattern:String = "ffffff"
        var alphaPattern:String = "ff"
        switch self.count {
        case 6 :
            rgbPattern = self
        case 7 :
            if self.hasPrefix("#") {
                rgbPattern = String(self.suffix(6))
            }
        case 8 :
            rgbPattern = String(self.prefix(6))
            alphaPattern = String(self.suffix(2))
        case 9 :
            if self.hasPrefix("#") {
                rgbPattern = String(self.suffix(8).prefix(6))
                alphaPattern = String(self.suffix(2))
            }
            break
        default :
            break
        }
        let rgbScanner = Scanner(string: rgbPattern)
        rgbScanner.currentIndex = rgbPattern.startIndex
        var rgbValue: UInt64 = 0
        rgbScanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        let alphaScanner = Scanner(string: alphaPattern)
        alphaScanner.currentIndex = alphaPattern.startIndex
        var alphaValue:UInt64 = 255
        alphaScanner.scanHexInt64(&alphaValue)
        return UIColor(red: CGFloat(r)/255.0, green: CGFloat(g)/255.0, blue: CGFloat(b)/255.0, alpha: CGFloat(alphaValue)/255.0)
    }
}
