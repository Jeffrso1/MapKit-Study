//
//  UIFontExtension.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import UIKit

extension UIFont {
    
    static var subtitleFont: UIFont {
        guard let font = UIFont(name: "Helvetica", size: 12) else { return UIFont() }
        return font
    }
    
}
