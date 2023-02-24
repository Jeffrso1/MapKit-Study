//
//  SearchScreenViewModel.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import Foundation
import MapKit

class SearchScreenViewModel {
    
    var mapItems: [MKMapItem] = []
    
    func getSearchItems(text: String, region: MKCoordinateRegion, completionHandler: @escaping (Result<[MKMapItem], NetworkError>) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = text
        searchRequest.region = region
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let _ = error {
                completionHandler(.failure(.requestFailed))
            }
            else if let response {
                self.mapItems = LocationManager.shared.sortMapItemsByDistance(items: response.mapItems)
                completionHandler(.success(response.mapItems))
            }
        }
    }
    
}
