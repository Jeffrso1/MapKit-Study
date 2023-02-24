//
//  LocationManager.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 20/02/23.
//

import MapKit

class LocationManager: NSObject {
    
    static let shared = LocationManager()
    
    var manager: CLLocationManager?
    var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(
            latitude: -22.900029,
            longitude: -43.299365
        ),
        span: MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005
        )
    )
    
    private override init() {}
    
}

// MARK: - Properties
extension LocationManager {
    
    var isStarted: Bool {
        manager != nil
    }
    
}

// MARK: - Methods
extension LocationManager {
    
    func start() {
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.distanceFilter = kCLDistanceFilterNone
        manager?.startUpdatingLocation()
    }
    
    private func handleAuthorizationStatus() {
        guard let manager else { return }
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestAlwaysAuthorization()
            
        case .restricted:
            print("Restricted authorization status.")
            
        case .denied:
            print("Denied authorization status.")
            
        case .authorizedAlways, .authorizedWhenInUse:
            guard let location = manager.location else { return }
            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.005,
                    longitudeDelta: 0.005
                )
            )
            NotificationCenter.default.post(name: .currentLocationChange, object: nil)
            
        @unknown default:
            break
        }
    }
    
    func userDistance(from location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = manager?.location else { return nil }
        return userLocation.distance(from: location)
    }
    
    func sortMapItemsByDistance(items: [MKMapItem]) -> [MKMapItem]{
        let sortedItems = items.sorted { previousItem, nextItem in
            guard let userLocation = manager?.location,
                  let previousLocation = previousItem.placemark.location,
                  let nextLocation = nextItem.placemark.location else { return true }
            let previousDistance = userLocation.distance(from: previousLocation)
            let nextDistance = userLocation.distance(from: nextLocation)
            return previousDistance < nextDistance
        }
        return sortedItems
    }
    
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorizationStatus()
    }
    
}
