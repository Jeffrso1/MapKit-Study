//
//  HomeScreenViewModel.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import Foundation
import MapKit

class HomeScreenViewModel {
    
    let categories: [MKPointOfInterestCategory] = [.hospital, .school, .hotel]
    
    var categoriesTitle: [String] {
        categories.map({
            var categoryDescription = String(describing: $0)
            categoryDescription.removeLast()
            categoryDescription.removeFirst(50)
            return categoryDescription
        })
    }
    
    var currentAnnotations: [MKAnnotation] = []
    
    func getPointsOfInterest(for category: MKPointOfInterestCategory, completion: @escaping (Result<[MKMapItem], NetworkError>) -> Void) {
        let center = LocationManager.shared.region.center
        let request = MKLocalPointsOfInterestRequest(center: center, radius: 1000)
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: [category])
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let _ = error {
                completion(.failure(.requestFailed))
            }
            else if let mapItems = response?.mapItems {
                completion(.success(mapItems))
            }
        }
    }
    
    func getPointsOfInterestForCategory(at index: Int, completion: @escaping (Result<[MKMapItem], NetworkError>) -> Void) {
        let currentCategory = categories[index]
        getPointsOfInterest(for: currentCategory, completion: completion)
    }
    
    func getDirections(destination: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, NetworkError>) -> Void) {
        guard let sourceCoordinate = LocationManager.shared.manager?.location?.coordinate else { return }
        let request = MKDirections.Request()
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let _ = error {
                completion(.failure(.requestFailed))
            }
            else if let response {
                let route = response.routes[0]
                completion(.success(route))
            }
        }
    }
    
}
