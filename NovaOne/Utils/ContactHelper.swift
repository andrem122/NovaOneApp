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
            mail.mailComposeDelegate = self

            from.present(mail, animated: true)
        } else {
            // Show failure alert
            print("Mail services are not available")
            return
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        // Handle the dissmisal of the mail view controller
        controller.dismiss(animated: true, completion: nil)
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
