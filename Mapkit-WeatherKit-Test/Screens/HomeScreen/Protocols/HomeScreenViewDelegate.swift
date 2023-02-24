//
//  HomeScreenViewDelegate.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import Foundation

protocol HomeScreenViewDelegate: AnyObject {
    
    func centralizeButtonWasTapped()
    func searchButtonWasTapped()
    func segmentedControlWasTapped(at index: Int)
    
}
