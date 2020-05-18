//
//  PopUpViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class PopUpActionViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var popUpTitleLabel: UILabel!
    @IBOutlet weak var popUpBodyLabel: UILabel!
    @IBOutlet weak var popUpActionButton: NovaOneButton!
    var popUpTitle = String()
    var popUpBody = String()
    var popUpActionButtonTitle = String()
    var popUpButtonActionCompletion: (() -> Void)?
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView() {
        // Sets the text values for the title and body label and the action button
        self.popUpTitleLabel.text = self.popUpTitle
        self.popUpBodyLabel.text = self.popUpBody
        self.popUpActionButton.setTitle(self.popUpActionButtonTitle, for: .normal)
    }
    
    // MARK: Actions
    @IBAction func popUpCancelButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func popUpActionButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        // Call the completion function/handler that happens after you tap the action button
        popUpButtonActionCompletion?()
    }
}
