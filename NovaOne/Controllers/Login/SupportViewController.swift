//
//  SupportViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class SupportViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var supportTextView: NovaOneTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        self.supportTextView.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 0, right: 0)
    }
    
    // MARK: Actions
    @IBAction func submitButtonTapped(_ sender: Any) {
    }
}
