//
//  Font.swift
//  Enhance
//
//  Created by Jonathan Baker on 4/22/17.
//
//

import UIKit

enum Font {

    // MARK: - GTWalsheimPro

    static func GTWalsheimPro(size: CGFloat) -> UIFont {
        return font(name: "GTWalsheimPro", size: size)
    }

    static func GTWalsheimProBoldOblique(size: CGFloat) -> UIFont {
        return font(name: "GTWalsheimPro-BoldOblique", size: size)
    }

    fileprivate static func font(name: String, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: name, size: size) else {
            fatalError("Failed to load font \"\(name)\"")
        }
        return font
    }
}
