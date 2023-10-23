//
//  HomeScreenViewController.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 20/02/23.
//

import UIKit
import MapKit

class HomeScreenViewController: BaseViewController<HomeScreenView> {
    
    private let viewModel = HomeScreenViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        mainView.mapView.delegate = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(managerLocationDidUpdate),
            name: .currentLocationChange,
            object: nil
        )
//        showFloodingPoints()
        showMatrixTiles()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationController()
    }
    
}

// MARK: - Helper Methods
extension HomeScreenViewController {
    
    static func prepareViewController() -> HomeScreenViewController {
        let mainView = HomeScreenView(region: LocationManager.shared.region)
        let controller = HomeScreenViewController(mainView: mainView)
        mainView.delegate = controller
        mainView.setupSegmentedControl(titles: controller.viewModel.categoriesTitle)
        return controller
    }
    
    private func setupLocationManager() {
        LocationManager.shared.start()
        guard let manager = LocationManager.shared.manager else { return }
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    private func setupNavigationController() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setAnnotationPins(for items: [MKMapItem]) {
        let annotations = items.map({ mapItem in
            let annotation = MKPointAnnotation()
            annotation.title = mapItem.name
            annotation.coordinate = mapItem.placemark.coordinate
            return annotation
        })
        viewModel.currentAnnotations = annotations
        mainView.mapView.addAnnotations(annotations)
    }
    
    private func showFloodingPoints() {
        for floodingCoordinate in viewModel.floodingCoordinates {
            mainView.addCircleOverlay(at: floodingCoordinate, radius: 20, title: "floodingPoint")
        }
    }
    
    private func showMatrixTiles() {
        let cases = [
            SusceptibilityClass.veryLow,
            SusceptibilityClass.low,
            SusceptibilityClass.medium,
            SusceptibilityClass.high,
            SusceptibilityClass.veryHigh
        ]
        for susceptibilityClass in cases {
            guard let polylines = viewModel.susceptibilityPopylines[susceptibilityClass.rawValue] else { continue }
            let multipolyline = MKMultiPolyline(polylines)
            multipolyline.title = susceptibilityClass.rawValue
            mainView.addMultipolylineOverlay(multipolyline)
        }
    }
    
    private func showFloodingIntersectionAlert() {
        let title = "Alerta!"
        let message = "É impossível encontrar uma rota que não passe por um alagamento. Aguarde no local ou dê meia volta."
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okAction = UIAlertAction(title: "Ok", style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
}

// MARK: - Actions
extension HomeScreenViewController {
    
    @objc
    private func managerLocationDidUpdate() {
//        mainView.startTrackingUserLocation()
//        mainView.addCircleOverlay(
//            at: LocationManager.shared.region.center,
//            radius: 1000
//        )
    }
    
}

// MARK: - HomeScreenViewDelegate
extension HomeScreenViewController: HomeScreenViewDelegate {
    
    func centralizeButtonWasTapped() {}
    
    func searchButtonWasTapped() {
        let controller = SearchScreenViewController.prepareViewController()
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func segmentedControlWasTapped(at index: Int) {
        mainView.removeCurrentRouteOverlayIfNeeded()
        viewModel.getPointsOfInterestForCategory(at: index) { result in
            self.mainView.mapView.removeAnnotations(self.viewModel.currentAnnotations)
            switch result {
            case .success(let mapItems):
                self.setAnnotationPins(for: mapItems)
                
            case .failure(_):
                print("DEU PROBLEMA")
            }
        }
    }
    
}

// MARK: - SearchScreenDelegate
extension HomeScreenViewController: SearchScreenDelegate {
    
    func didSelectRow(with mapItem: MKMapItem) {
        guard let location = mapItem.placemark.location else { return }
        let span = MKCoordinateSpan(
            latitudeDelta: 0.005,
            longitudeDelta: 0.005
        )
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: span
        )
        mainView.resetSegmentedControl()
        mainView.mapView.removeAnnotations(viewModel.currentAnnotations)
//        mainView.updateMap(to: region)
        setAnnotationPins(for: [mapItem])
    }
    
}

// MARK: - MKMapViewDelegate
extension HomeScreenViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            switch overlay.title {
            case "floodingPoint":
                circleRenderer.fillColor = .systemBlue
            default:
                circleRenderer.fillColor = .red
            }
            return circleRenderer
        }
        if let overlay = overlay as? MKMultiPolyline {
            let route = MKMultiPolylineRenderer(multiPolyline: overlay)
            switch overlay.title {
            case "Muito Baixo":
                route.strokeColor = .blue
                route.fillColor = .blue
            case "Baixo":
                route.strokeColor = .green
                route.fillColor = .green
            case "Médio":
                route.strokeColor = .yellow
                route.fillColor = .yellow
            case "Alto":
                route.strokeColor = .orange
                route.fillColor = .orange
            case "Muito Alto":
                route.strokeColor = .red
                route.fillColor = .red
            default:
                break
            }
            route.lineWidth = 2
            route.alpha = 0.5
            return route
        }
        let polygon = MKPolygonRenderer(overlay: overlay)
        polygon.strokeColor = .red
        return polygon
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = String(describing: MKPointAnnotation.self)
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        viewModel.getRoutes(destination: annotation.coordinate) { response in
            switch response {
            case .success(let routes):
                guard let rightRoute = routes.first(where: { !self.viewModel.checkFloodingPointIntersection(for: $0.polyline) }) else {
                    self.showFloodingIntersectionAlert()
                    return
                }
                self.mainView.addRouteOverlay(route: rightRoute)
                
            case .failure(_):
                print("DEU PROBLEMA")
            }
        }
    }
    
}

public extension MKMapView {

    func metersToPoints(meters: Double) -> Double {

        let deltaPoints = 500.0

        let point1 = CGPoint(x: 0, y: 0)
        let coordinate1 = convert(point1, toCoordinateFrom: self)
        let location1 = CLLocation(latitude: coordinate1.latitude, longitude: coordinate1.longitude)

        let point2 = CGPoint(x: 0, y: deltaPoints)
        let coordinate2 = convert(point2, toCoordinateFrom: self)
        let location2 = CLLocation(latitude: coordinate2.latitude, longitude: coordinate2.longitude)

        let deltaMeters = location1.distance(from: location2)

        let pointsPerMeter = deltaPoints / deltaMeters

        return meters * pointsPerMeter
    }
}

public class ZoomingPolylineRenderer : MKPolylineRenderer {

    private var mapView: MKMapView!
    private var polylineWidth: Double! // Meters

    convenience public init(polyline: MKPolyline, mapView: MKMapView, polylineWidth: Double) {
        self.init(polyline: polyline)

        self.mapView = mapView
        self.polylineWidth = polylineWidth
    }

    override public func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        self.lineWidth = CGFloat(mapView.metersToPoints(meters: polylineWidth))
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct HomeScreenViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        ForEach (deviceNames, id: \.self) { deviceName in
            UIViewControllerPreview {
                HomeScreenViewController.prepareViewController()
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
    
}
#endif
