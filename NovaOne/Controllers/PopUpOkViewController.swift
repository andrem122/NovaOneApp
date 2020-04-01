//
//  PopUpOkViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class PopUpOkViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var popUpTitleLabel: UILabel!
    @IBOutlet weak var popUpBodyLabel: UILabel!
    var popUpTitle = String()
    var popUpBody = String()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
    }
    
    func setupView() {
        // Sets the text values for the title and body label and the action button
        self.popUpTitleLabel.text = self.popUpTitle
        self.popUpBodyLabel.text = self.popUpBody
    }
    
    // MARK: Actions
    @IBAction func popUpActionButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}
