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
    
}

// MARK: - Actions
extension HomeScreenViewController {
    
    @objc
    private func managerLocationDidUpdate() {
        mainView.startTrackingUserLocation()
        mainView.addCircleOverlay(
            at: LocationManager.shared.region.center,
            radius: 1000
        )
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
        mainView.updateMap(to: region)
        setAnnotationPins(for: [mapItem])
    }
    
}

// MARK: - MKMapViewDelegate
extension HomeScreenViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            circleRenderer.strokeColor = .red.withAlphaComponent(0.5)
            return circleRenderer
        }
        
        let route = MKPolylineRenderer(overlay: overlay)
        route.strokeColor = .blue
        return route
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }
        let identifier = String(describing: MKPointAnnotation.self)
        let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect annotation: MKAnnotation) {
        viewModel.getDirections(destination: annotation.coordinate) { response in
            switch response {
            case .success(let route):
                self.mainView.addRouteOverlay(route: route)
                
            case .failure(_):
                print("DEU PROBLEMA")
            }
        }
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
