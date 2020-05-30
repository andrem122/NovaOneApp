//
//  NovaOneObjectContainerProtocol.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/24/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

protocol NovaOneObjectContainer {
    // Contains the properties and methods needed for a object container
    
    // MARK: Properties
    var containerView: UIView! { get set }
    var objectCount: Int { get set }
    
    // MARK: Methods
    func showCoreDataOrRequestData()
    func saveToCoreData(objects: [Decodable])
    func getData()
}
