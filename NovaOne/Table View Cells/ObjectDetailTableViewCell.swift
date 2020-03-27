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
    
    // Assigns values for cell properties
    func setup(cellIcon: UIImage, cellTitle: String, cellTitleValue: String, canUpdateValue: Bool) {
        
        //self.cellIcon.image = cellIcon
        self.cellTitleLabel.text = cellTitle
        self.cellTitleValueLabel.text = cellTitleValue
        
        // If the value of the object can not be updated in the database,
        // remove the right angle icon and set trailing
        // constant of cellTitleValueLabel to 8 points from superview
        if !canUpdateValue {
            
            // Trailing constraint
            self.contentView.addConstraint(NSLayoutConstraint(item: self.cellTitleValueLabel!, attribute: .trailing, relatedBy: .equal, toItem: self.cellTitleLabel.superview, attribute: .trailing, multiplier: 1, constant: 16))
            
            // Leading constraint
            self.contentView.addConstraint(NSLayoutConstraint(item: self.cellTitleValueLabel!, attribute: .leading, relatedBy: .greaterThanOrEqual, toItem: self.cellTitleLabel.superview, attribute: .leading, multiplier: 1, constant: 0))
            
            // Center vertically
            self.contentView.addConstraint(NSLayoutConstraint(item: self.cellTitleValueLabel!, attribute: .centerY, relatedBy: .equal, toItem: self.contentView, attribute: .centerY, multiplier: 1, constant: 0))
            
            
        }
        
    }

}
