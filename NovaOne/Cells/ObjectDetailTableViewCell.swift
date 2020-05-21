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
    var objectDetailItem: ObjectDetailItem? {
        didSet {
            self.cellTitleLabel.text = self.objectDetailItem?.title
            self.cellTitleValueLabel.text = self.objectDetailItem?.titleValue
        }
    }

}
