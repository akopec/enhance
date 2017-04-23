//
//  UIColor.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/23/17.
//
//

import UIKit

extension UIColor {
    public convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red: CGFloat = {
            let component = (hex & 0xFF0000) >> 16
            return CGFloat(component) / 255
        }()
        let green: CGFloat = {
            let component = (hex & 0x00FF00) >> 8
            return CGFloat(component) / 255
        }()
        let blue: CGFloat = {
            let component = (hex & 0x0000FF)
            return CGFloat(component) / 255
        }()
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
