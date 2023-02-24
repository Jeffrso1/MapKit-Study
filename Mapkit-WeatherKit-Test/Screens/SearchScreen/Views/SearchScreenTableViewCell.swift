//
//  SearchScreenTableViewCell.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import UIKit
import MapKit

class SearchScreenTableViewCell: UITableViewCell, TableViewCellIdentifierProtocol {
    
    private lazy var geolocationIcon: UIImageView = {
        let image = UIImage(systemName: "location.north.circle")
        let imageView = UIImageView(image: image)
        imageView.transform = imageView.transform.rotated(by: .pi)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        return imageView
    }()
    
    private lazy var distanceLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.font = .subtitleFont
        
        return label
    }()
    
    private lazy var distanceStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.addArrangedSubview(geolocationIcon)
        stackView.addArrangedSubview(distanceLabel)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var locationName: UILabel = {
        let label = UILabel(frame: .zero)
        
        return label
    }()
    
    private lazy var locationAddress: UILabel = {
        let label = UILabel(frame: .zero)
        
        return label
    }()
    
    private lazy var textStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .vertical
        stackView.addArrangedSubview(locationName)
        stackView.addArrangedSubview(locationAddress)
        stackView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var mainStackView: UIStackView = {
        let stackView = UIStackView(frame: .zero)
        stackView.axis = .horizontal
        stackView.addArrangedSubview(distanceStackView)
        stackView.addArrangedSubview(textStackView)
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        applySetup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Helper Methods
extension SearchScreenTableViewCell {
    
    private func setupMainStackView() {
        contentView.addSubview(mainStackView)
        NSLayoutConstraint.activate([
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
    
    private func setupDistanceStackView() {
        NSLayoutConstraint.activate([
            geolocationIcon.heightAnchor.constraint(equalToConstant: 30),
            geolocationIcon.widthAnchor.constraint(equalToConstant: 30),
            distanceStackView.widthAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    func setupCell(for mapItem: MKMapItem, distance: CLLocationDistance?) {
        locationName.text = mapItem.name
        locationAddress.text = mapItem.placemark.thoroughfare
        
        if let distance {
            let quilometerDistance = distance / 1000
            distanceLabel.text = String(format: "%.2f km", quilometerDistance)
        }
    }
    
}

// MARK: - ViewSetupProtocol
extension SearchScreenTableViewCell: ViewSetupProtocol {
    
    func setLayout() {
        setupMainStackView()
        setupDistanceStackView()
    }
    
    func setStyle() {}
    
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SearchScreenTableViewCell_Preview: PreviewProvider {
    
    static var previews: some View {
        ForEach (deviceNames, id: \.self) { deviceName in
            UIViewPreview {
                let cell = SearchScreenTableViewCell(style: .default, reuseIdentifier: SearchScreenTableViewCell.identifier)
                let coordinate = CLLocationCoordinate2D(
                    latitude: -22.980347,
                    longitude: -43.235051
                )
                let placemark = MKPlacemark(coordinate: coordinate)
                let mapItem = MKMapItem(placemark: placemark)
                let distance: CLLocationDistance? = {
                    guard let location = mapItem.placemark.location else { return nil }
                    return LocationManager.shared.userDistance(from: location)
                }()
                cell.setupCell(for: mapItem, distance: distance)
                return cell
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
            .frame(
                width: UIScreen.main.bounds.width,
                height: 70
            )
        }
    }
    
}
#endif
