//
//  AddAddressTableViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAddressTableViewCell: UITableViewCell {
    
    // MARK: Properties
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var deleteCellRowButton: UIButton!
    
    
    func setupCell(address: String, cellRow: Int) {
        self.addressLabel.text = address
        self.deleteCellRowButton.tag = cellRow
    }
    
}
