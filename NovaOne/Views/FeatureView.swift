//
//  FeatureView.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class FeatureView: UIView {
    
    @IBOutlet weak var featureImage: UIImageView!
    @IBOutlet weak var featureTitle: UILabel!
    @IBOutlet weak var featureSubtext: UILabel!
    
    var slide: Slide? {
        didSet {
            guard let imageName = self.slide?.imageName else { return }
            self.featureImage.image = UIImage(named: imageName)
            self.featureTitle.text = self.slide?.title
            self.featureSubtext.text = self.slide?.subtitle
        }
    }
    
}
