//
//  Colors.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit

/*
 The ColorPalette makes it easy to access colors in the app's color scheme.
 */
struct ColorPalette {
    
    static let primaryGray = UIColor(red: 38 / 255, green: 38 / 255, blue: 38 / 255, alpha: 1.0)
    static let secondaryGray = UIColor(red: 85 / 255, green: 85 / 255, blue: 85 / 255, alpha: 1.0)
    static let blue = UIColor(red: 64 / 255, green: 168 / 255, blue: 227 / 255, alpha: 1.0)
    static let green = UIColor(red: 102 / 255, green: 204 / 255, blue: 153 / 255, alpha: 1.0)
    static let grassGreen = UIColor(red: 96 / 255, green: 128 / 255, blue: 56 / 255, alpha: 1.0)
    static let gold = UIColor(red: 248 / 255, green: 193 / 255, blue: 4 / 255, alpha: 1.0)
    static let red = UIColor.systemRed
    static let white = UIColor.white
    static let disabledWhite = UIColor.white.withAlphaComponent(0.5)
}
