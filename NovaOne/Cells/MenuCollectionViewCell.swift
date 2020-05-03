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
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    let iconImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage()
        image.tintColor = Defaults.novaOneColor
        image.contentMode = .scaleAspectFill
        return image
    }()
    
    var menuOption: MenuOption? {
        didSet {
            // After setting menuOption, set text for the label
            self.menuOptionNameLabel.text = self.menuOption?.name
            guard let imageName = self.menuOption?.imageName else { return }
            self.iconImage.image = UIImage(systemName: imageName)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            if self.isHighlighted {
                self.backgroundColor = .lightGray
            } else {
                self.backgroundColor = .white
            }
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        // Add subviews to superview
        self.addSubview(self.menuOptionNameLabel)
        self.addSubview(self.iconImage)
        
        // Add constraints to subviews
        self.addConstraints(with: "H:|-8-[v0(30)]-8-[v1]|", views: self.iconImage, self.menuOptionNameLabel)
        self.addConstraints(with: "V:|[v0(30)]|", views: self.iconImage)
        
        // Center icon image to superviews Y center value
        self.addConstraint(NSLayoutConstraint(item: self.iconImage, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))
        
        // Center label to icon image
        self.addConstraint(NSLayoutConstraint(item: self.menuOptionNameLabel, attribute: .centerY, relatedBy: .equal, toItem: self.iconImage, attribute: .centerY, multiplier: 1, constant: 0))
        
    }
    
}
