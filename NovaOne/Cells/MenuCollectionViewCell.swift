//
//  MenuCollectionViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: BaseCell {
    
    let menuOptionNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Menu Option"
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        self.addSubview(self.menuOptionNameLabel)
    }
}
