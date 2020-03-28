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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setup(weekDay: String) {
        // Set up the cell properties with values
        self.optionLabel.text = weekDay
    }
    
    func toggleCheckMark(cell: EnableOptionTableViewCell) {
        // Toggles the check mark image from hidden to visible
        if cell.checkMarkImage.isHidden {
            cell.checkMarkImage.isHidden = false // Show the check mark image
        } else {
            // Check mark is not hidden, so hide it
            cell.checkMarkImage.isHidden = true
        }
    }

}
