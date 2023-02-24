//
//  BaseViewController.swift
//  Mapkit-WeatherKit-Test
//
//  Created by Jefferson Silva on 20/02/23.
//

import UIKit

open class BaseViewController<V: UIView>: UIViewController {
    
    public let mainView: V
    
    public init(mainView: V) {
        self.mainView = mainView
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        super.loadView()
        view = mainView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
