//
//  Color.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/22/17.
//
//

import UIKit

enum Color {
    static func teal() -> UIColor {
        return UIColor(red: 80.0/255.0, green: 227.0/255.0, blue: 194.0/255.0, alpha: 1.0)
    }

    static func darkTeal() -> UIColor {
        return UIColor(red: 39.0/255.0, green: 50.0/255.0, blue: 48.0/255.0, alpha: 1.0)
    }

    static func tealOverlay() -> UIColor {
        return teal().withAlphaComponent(0.75)
    }
}
