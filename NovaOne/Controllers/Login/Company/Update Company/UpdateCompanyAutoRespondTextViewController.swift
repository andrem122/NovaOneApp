//
//  UpdateCompanyAutoRespondTextViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateCompanyAutoRespondTextViewController: UIViewController {
    
    var autoRespondText: String?
    @IBOutlet weak var textView: NovaOneTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTextField()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    func setupTextField() {
        // Sets up the text field
        guard let autoRespondText = self.autoRespondText else { return }
        self.textView.text = autoRespondText
    }

}
