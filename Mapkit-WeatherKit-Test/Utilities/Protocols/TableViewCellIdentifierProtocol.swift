//
//  TableViewCellIdentifierProtocol.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 21/02/23.
//

import UIKit

protocol TableViewCellIdentifierProtocol: UITableViewCell {}

extension TableViewCellIdentifierProtocol {
    
    static var identifier: String { String(describing: Self.self) }
    
}
