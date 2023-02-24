//
//  SearchScreenDelegate.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import Foundation
import MapKit

protocol SearchScreenDelegate: AnyObject {
    
    func didSelectRow(with mapItem: MKMapItem)
    
}
