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
import CoreData

protocol NovaOneTableViewCellDelegate {
    func didTapEmailButton(email: String)
    func didTapCallButton(phoneNumber: String)
}

class NovaOneTableViewCell: UITableViewCell {

    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabelOne: UILabel!
    @IBOutlet weak var subTitleLabelTwo: UILabel!
    @IBOutlet weak var subTitleLabelThree: UILabel!
    var email: String?
    var phoneNumber: String?
    var delegate: NovaOneTableViewCellDelegate?
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    // MARK: Methods
    
    // Set up the properties above for each cell by passing in an appointment object from
    // cellForRowAt IndexPath function
    func setup(title: String,
                   subTitleOne: String,
                   subTitleTwo: String,
                   subTitleThree: String,
                   email: String?,
                   phoneNumber: String?) {
        
        // Set text for each UILabel
        self.titleLabel.text = title
        self.subTitleLabelOne.text = subTitleOne
        self.subTitleLabelTwo.text = subTitleTwo
        self.subTitleLabelThree.text = subTitleThree
        self.email = email
        self.phoneNumber = phoneNumber
        
        // Hide buttons based on whether or not there is an email or phone number
        let email = self.email == nil ? "" : self.email!
        if email.isEmpty {
            self.emailButton.isHidden = true
        } else {
            self.emailButton.isHidden = false
        }
        
        let phoneNumber = self.phoneNumber == nil ? "" : self.phoneNumber!
        if phoneNumber.isEmpty {
            self.callButton.isHidden = true
        } else {
            self.callButton.isHidden = false
        }
        
    }
    
    
    // MARK: Actions
    @IBAction func emailButtonTapped(_ sender: Any) {
        guard let email = self.email else { return }
        self.delegate?.didTapEmailButton(email: email)
    }
    
    @IBAction func callButtonTapped(_ sender: Any) {
        guard let phoneNumber = self.phoneNumber else { return }
        self.delegate?.didTapCallButton(phoneNumber: phoneNumber)
    }
}
