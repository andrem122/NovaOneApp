//
//  DaysEnabledTableViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/27/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class EnableOptionTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var checkMarkImage: UIImageView!
    
    
    // MARK: Methods
    func setup(option: String) {
        // Set up the cell properties with values
        self.optionLabel.text = option
    }
    
    func toggleCheckMark(cell: EnableOptionTableViewCell) -> Bool {
        // Toggles the check mark image from hidden to visible
        
        if cell.checkMarkImage.isHidden {
            cell.checkMarkImage.isHidden = false // Show the check mark image
            return true // check mark image is now visible so return true
        } else {
            // Check mark is not hidden, so hide it
            cell.checkMarkImage.isHidden = true
            return false // check mark image is not visible so return false
        }
        
    }
    
    func prepareCellForReuse(cell: EnableOptionTableViewCell, enableOption: EnableOption) {
        // Sets up the reused cell based on attributes in the EnableOption item
        if enableOption.selected {
            cell.checkMarkImage.isHidden = false
        } else {
            cell.checkMarkImage.isHidden = true
        }
        
        cell.setup(option: enableOption.option)
    }
    
}
