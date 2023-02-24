//
//  SearchScreenViewController.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import UIKit
import CoreLocation

class SearchScreenViewController: UITableViewController {
    
    private let viewModel = SearchScreenViewModel()
    var delegate: SearchScreenDelegate?
    
    override func viewDidLoad() {
        tableView.register(SearchScreenTableViewCell.self, forCellReuseIdentifier: SearchScreenTableViewCell.identifier)
        setupNavigationController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
}

// MARK: - Helper Methods
extension SearchScreenViewController {
    
    static func prepareViewController() -> SearchScreenViewController {
        let controller = SearchScreenViewController(style: .plain)
        return controller
    }
    
    private func setupNavigationController() {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Buscar localização"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
    }
    
}

// MARK: - UITableViewDataSource
extension SearchScreenViewController {
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: SearchScreenTableViewCell.identifier,
            for: indexPath
        ) as? SearchScreenTableViewCell else { fatalError() }
        
        let mapItem = viewModel.mapItems[indexPath.row]
        let distance: CLLocationDistance? = {
            guard let location = mapItem.placemark.location else { return nil }
            return LocationManager.shared.userDistance(from: location)
        }()
        cell.setupCell(for: mapItem, distance: distance)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.mapItems.count
    }
    
}

// MARK: - UITableViewDelegate
extension SearchScreenViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let mapItem = viewModel.mapItems[indexPath.row]
        delegate?.didSelectRow(with: mapItem)
        navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UISearchResultsUpdating
extension SearchScreenViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        let region = LocationManager.shared.region
        viewModel.getSearchItems(
            text: text,
            region: region) { _ in
                self.tableView.reloadData()
            }
    }
    
}

// MARK: - Preview
#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct SearchScrenTableViewController_Preview: PreviewProvider {
    
    static var previews: some View {
        ForEach (deviceNames, id: \.self) { deviceName in
            UIViewControllerPreview {
                SearchScreenViewController()
            }
            .previewDevice(PreviewDevice(rawValue: deviceName))
            .previewDisplayName(deviceName)
        }
    }
    
}
#endif
