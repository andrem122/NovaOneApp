//
//  ObjectDetail.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

protocol NovaOneObjectDetail {
    // A bunch of properties we need for the object detail view to work
    var objectDetailItems: [ObjectDetailItem] { get set } // Can read ('get' keyword) and edit the property ('set' keyword)
    var titleLabel: UILabel! { get }
    var objectDetailTableView: UITableView! { get }
    var alertService: AlertService { get set }
    var previousViewController: UIViewController? { get set }
    var coreDataObjectId: Int32? { get set }
    
    // Methods
    func getCoreDataObject()
}
