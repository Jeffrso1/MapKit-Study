//
//  ViewSetupProtocol.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 20/02/23.
//

import UIKit

protocol ViewSetupProtocol: UIView {
    
    func setLayout()
    func setStyle()
    
}

extension ViewSetupProtocol {
    
    func applySetup() {
        self.setLayout()
        self.setStyle()
    }
    
}
