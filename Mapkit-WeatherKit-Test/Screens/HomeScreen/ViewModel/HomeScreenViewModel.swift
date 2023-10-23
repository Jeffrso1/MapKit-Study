//
//  HomeScreenViewModel.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import Foundation
import MapKit

class HomeScreenViewModel {
    
    init() {
        readDataFromFile(fileName: "2x2_Coordenadas", type: "txt")
    }
    
    let categories: [MKPointOfInterestCategory] = [.hospital, .school, .hotel]
    
    let floodingCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: -22.899999, longitude: -43.297515),
        CLLocationCoordinate2D(latitude: -22.902271, longitude: -43.299725),
        CLLocationCoordinate2D(latitude: -22.900389, longitude: -43.298080),
    ]
    
    var coordinates: [SusceptibilityCoordinate] = [] {
        didSet {
            filterPolylines()
        }
    }
    
    var susceptibilityPopylines: [String: [MKPolyline]] = [
        SusceptibilityClass.veryLow.rawValue : [],
        SusceptibilityClass.low.rawValue : [],
        SusceptibilityClass.medium.rawValue : [],
        SusceptibilityClass.high.rawValue : [],
        SusceptibilityClass.veryHigh.rawValue : [],
    ]
    
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
    
    func getRoutes(destination: CLLocationCoordinate2D, completion: @escaping (Result<[MKRoute], NetworkError>) -> Void) {
        guard let sourceCoordinate = LocationManager.shared.manager?.location?.coordinate else { return }
        let request = MKDirections.Request()
        let sourcePlacemark = MKPlacemark(coordinate: sourceCoordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .walking
        request.requestsAlternateRoutes = true
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let _ = error {
                completion(.failure(.requestFailed))
            }
            else if let response {
                let routes = response.routes
                completion(.success(routes))
            }
        }
    }
    
    func getFirstWalkingRoute(destination: CLLocationCoordinate2D, completion: @escaping (Result<MKRoute, NetworkError>) -> Void) {
        getRoutes(destination: destination) { result in
            switch result {
            case .success(let routes):
                let firstWalkingRoute = routes[0]
                completion(.success(firstWalkingRoute))
            case .failure(_):
                completion(.failure(.requestFailed))
            }
        }
    }
    
    private func getMatrixJSON() -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: "coordinates", ofType: "json"),
               let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return jsonData
            }
        } catch {
            print(error)
        }
        return nil
    }
    
    func readDataFromFile(fileName: String, type: String) {
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: type) else { return }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)
            self.coordinates = csvStringToArray(stringCSV: contents)
        } catch {
            fatalError("Oops!")
        }
    }
    
    func csvStringToArray(stringCSV: String) -> [SusceptibilityCoordinate] {
        // create an empty 2-D array to hold the CSV data.
        var dataArray: [SusceptibilityCoordinate] = []

        // parse the CSV into rows.
        var rows: [String] = stringCSV.components(separatedBy: "\n")
        rows.removeFirst()

        // append each row (1-D array) to dataArray (filling the 2-D array).
        for row in rows {
            let columns = row.components(separatedBy: ";")
            let longitude = Double(columns[3].replacingOccurrences(of: ",", with: "."))!
            let latitude = Double(columns[4].replacingOccurrences(of: ",", with: "."))!
            var susceptibility = columns[5]
            if susceptibility.last! == "\r" {
                susceptibility = String(susceptibility.dropLast())
            }
            let newCoordinate = SusceptibilityCoordinate(
                latitude: latitude,
                longitude: longitude,
                susceptibilityString: susceptibility
            )
//            if newCoordinate.susceptibility != .low && newCoordinate.susceptibility != .veryLow {
                dataArray.append(newCoordinate)
//            }
        }
        return dataArray
    }
    
    func filterPolylines() {
        var startingPoint = coordinates.first!
        var previousPoint = coordinates.first!
        for (index, coordinate) in coordinates.enumerated() {
            if coordinate.susceptibility != startingPoint.susceptibility ||
                abs(coordinate.latitude - previousPoint.latitude) > 0.000001
            {
                var edgeList = [startingPoint]
                let finalPoint = coordinates[index - 1]
                if finalPoint.latitude != startingPoint.latitude || finalPoint.longitude != startingPoint.longitude {
                    edgeList.append(finalPoint)
                }
                let newPolyline = MKPolyline(
                    coordinates: edgeList.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) }),
                    count: edgeList.count
                )
                newPolyline.title = startingPoint.susceptibility.rawValue
                susceptibilityPopylines[startingPoint.susceptibility.rawValue]?.append(newPolyline)
                startingPoint = coordinate
            }
            previousPoint = coordinate
        }
    }
    
}

struct SusceptibilityCoordinate {
    
    let latitude: Double
    let longitude: Double
    let susceptibility: SusceptibilityClass
    
    init(latitude: Double, longitude: Double, susceptibilityString: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.susceptibility = SusceptibilityClass(rawValue: susceptibilityString)!
    }
    
}

struct SusceptibilityEdge {
    
    let pointA: SusceptibilityCoordinate
    let pointB: SusceptibilityCoordinate?
    
}

enum SusceptibilityClass: String {
    case veryLow = "Muito Baixo"
    case low = "Baixo"
    case medium = "Médio"
    case high = "Alto"
    case veryHigh = "Muito Alto"
}

// MARK: - Helper Methods
extension HomeScreenViewModel {
    
    func checkFloodingPointIntersection(for polyline: MKPolyline) -> Bool {
        for floodingCoordinate in floodingCoordinates {
            let origin = MKMapPoint(floodingCoordinate)
            let size = MKMapSize(width: 20, height: 20)
            let mapRect = MKMapRect(origin: origin, size: size)
            if polyline.intersects(mapRect) { return true }
        }
        return false
    }
    
}
