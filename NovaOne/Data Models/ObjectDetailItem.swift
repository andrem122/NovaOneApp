//
//  ObjectDetail.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/20/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

class ObjectDetailItem: NSObject {
    // A model class to represent the data for the items for each ObjectDetailTableViewCell
    
    let title: String
    let titleValue: String
    
    init(title: String, titleValue: String) {
        self.title = title
        self.titleValue = titleValue
    }
}
