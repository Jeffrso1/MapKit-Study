//
//  HomeScreenView.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 20/02/23.
//

import UIKit
import MapKit

class HomeScreenView: UIView {
    
    weak var delegate: HomeScreenViewDelegate?
    
    private lazy var centralizeButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "location.fill"), for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapCentralizeButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        button.backgroundColor = .white
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.addArrangedSubview(searchButton)
        stackView.addArrangedSubview(centralizeButton)
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    lazy var mapView: MKMapView = {
        let mapView = MKMapView(frame: .zero)
//        mapView.showsUserLocation = true
        mapView.camera.heading = 500.0
        mapView.isPitchEnabled = true
        mapView.showsBuildings = true
        mapView.setRegion(MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: -22.900029,
                longitude: -43.299365
            ),
            span: MKCoordinateSpan(
                latitudeDelta: 0.005,
                longitudeDelta: 0.005
            )
        ), animated: true)
//        mapView.setCameraZoomRange(
//            MKMapView.CameraZoomRange(minCenterCoordinateDistance: 4000),
//            animated: false
//        )
        
        return mapView
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(frame: .zero)
        let normalTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
        let selectedTitleAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        segmentedControl.addTarget(self, action: #selector(didTapSegmentedControl), for: .primaryActionTriggered)
        segmentedControl.backgroundColor = .white
        segmentedControl.selectedSegmentTintColor = .lightGray
        segmentedControl.setTitleTextAttributes(normalTitleAttributes, for: .normal)
        segmentedControl.setTitleTextAttributes(selectedTitleAttributes, for: .selected)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        
        return segmentedControl
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.addArrangedSubview(mapView)
        stackView.addArrangedSubview(segmentedControl)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    convenience init(region: MKCoordinateRegion) {
        self.init(frame: .zero)
        self.applySetup()
//        mapView.region = region
    }
    
}

// MARK: - Helper
extension HomeScreenView {
    
    func updateMap(to region: MKCoordinateRegion) {
        mapView.setRegion(region, animated: true)
    }
    
    func startTrackingUserLocation() {
        mapView.setUserTrackingMode(.follow, animated: true)
    }
    
    private func setupMainStackView() {
        self.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: self.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            segmentedControl.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func setupButtonStackView() {
        let buttons = [searchButton, centralizeButton]
        for button in buttons {
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 50),
                button.widthAnchor.constraint(equalToConstant: 50),
            ])
        }
        mapView.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.trailingAnchor.constraint(equalTo: mapView.trailingAnchor, constant: -10),
            buttonsStackView.topAnchor.constraint(equalTo: mapView.layoutMarginsGuide.topAnchor, constant: 10),
        ])
    }
    
    func addCircleOverlay(at center: CLLocationCoordinate2D, radius: CLLocationDistance, title: String? = nil) {
        let overlay = MKCircle(center: center, radius: radius)
        if let title { overlay.title = title }
        mapView.addOverlay(overlay)
    }
    
    func addPolygonOverlay(_ polygon: MKPolygon) {
        mapView.addOverlay(polygon)
    }
    
    func addRouteOverlay(route: MKRoute) {
        removeCurrentRouteOverlayIfNeeded()
        let title = String(describing: MKRoute.self)
        let overlay = route.polyline
        overlay.title = title
        mapView.addOverlay(route.polyline)
    }
    
    func addPolylineOverlay(_ polyline: MKPolyline) {
        mapView.addOverlay(polyline)
    }
    
    func addMultipolylineOverlay(_ multipolyline: MKMultiPolyline) {
        mapView.addOverlay(multipolyline)
    }
    
    func removeCurrentRouteOverlayIfNeeded() {
        let title = String(describing: MKRoute.self)
        if let routeOverlay = mapView.overlays.first(where: { $0.title == title }) {
            mapView.removeOverlay(routeOverlay)
        }
    }
    
    func setupSegmentedControl(titles: [String]) {
        for (index, title) in titles.enumerated() {
            segmentedControl.insertSegment(withTitle: title, at: index, animated: false)
        }
    }
    
    func resetSegmentedControl() {
        segmentedControl.selectedSegmentIndex = UISegmentedControl.noSegment
    }
    
}

// MARK: - Actions
extension HomeScreenView {
    
    @objc
    func didTapCentralizeButton() {
        mapView.setUserTrackingMode(.follow, animated: true)
        delegate?.centralizeButtonWasTapped()
    }
    
    @objc
    func didTapSearchButton() {
        delegate?.searchButtonWasTapped()
    }
    
    @objc
    func didTapSegmentedControl() {
        delegate?.segmentedControlWasTapped(at: segmentedControl.selectedSegmentIndex)
    }
    
}

// MARK: - ViewSetupProtocol
extension HomeScreenView: ViewSetupProtocol {
    
    func setLayout() {
        setupMainStackView()
        setupButtonStackView()
    }
    
    func setStyle() {}
    
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

let deviceNames = [
    "iPhone 8",
    "iPhone 12 mini",
    "iPhone 14 Pro Max",
]

@available(iOS 13.0, *)
struct HomeScreenView_Preview: PreviewProvider {
    
    static var previews: some View {
        ForEach(deviceNames, id: \.self) { deviceName in
            UIViewPreview {
                let view = HomeScreenView(
                    region: MKCoordinateRegion(
                        center: CLLocationCoordinate2D(
                            latitude: -22.980347,
                            longitude: -43.235051
                        ),
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.005,
                            longitudeDelta: 0.005
                        )
                    )
                )
                view.setupSegmentedControl(titles: ["Hospitais", "Polícia", "Hospedagem"])
                return view
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
    
}
#endif
