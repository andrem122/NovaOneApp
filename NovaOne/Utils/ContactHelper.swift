//
//  ContactHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 8/16/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
import MessageUI

class ContactHelper: UIViewController, MFMailComposeViewControllerDelegate {
    // A helper class for contacting activities
    
    func sendEmail(email: String, present from: UIViewController) {
        // Opens an email sender for the person to send an email
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])

            from.present(mail, animated: true)
        } else {
            // show failure alert
            print("mail fail")
        }
    }
    
    func call(phoneNumber: String) {
        // Calls the number
        let unformattedPhoneNumber = phoneNumber.replacingOccurrences(of: "[\\(\\)\\s-]", with: "", options: .regularExpression, range: nil)
        if let url = URL(string: "tel://\(unformattedPhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
