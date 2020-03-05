//
//  TableViewCell.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/28/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
import UIKit
import MessageUI

class NovaOneTableViewCell: UITableViewCell, MFMailComposeViewControllerDelegate {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabelOne: UILabel!
    @IBOutlet weak var subTitleLabelTwo: UILabel!
    @IBOutlet weak var subTitleLabelThree: UILabel!
    
    // MARK: Methods
    
    // Set up the properties above for each cell by passing in an appointment object from
    // cellForRowAt IndexPath function
    func setup(title: String,
                   subTitleOne: String,
                   subTitleTwo: String,
                   subTitleThree: String) {
        
        // Set text for each UILabel
        self.titleLabel.text = title
        self.subTitleLabelOne.text = subTitleOne
        self.subTitleLabelTwo.text = subTitleTwo
        self.subTitleLabelThree.text = subTitleThree
        
    }
    
    
    // MARK: Actions
    
    // Email on tap of email button
    @IBAction func emailButtonTapped(_ sender: Any, email: String) {
        
    }
    
    // Call phone number on tap of phone button
    @IBAction func callButtonTapped(_ sender: Any, phoneNumber: String) {
        
        if let url = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
        
    }
    
    
    
}
