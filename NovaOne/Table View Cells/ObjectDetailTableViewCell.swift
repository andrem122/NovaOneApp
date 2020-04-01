//
//  ObjectDetailTableViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class ObjectDetailTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var cellTitleLabel: UILabel!
    @IBOutlet weak var cellTitleValueLabel: UILabel!
    
    func setup(cellTitle: String, cellTitleValue: String) {
        // Set up the title and title value for each cell
        
        self.cellTitleLabel.text = cellTitle
        self.cellTitleValueLabel.text = cellTitleValue
        
    }

}
