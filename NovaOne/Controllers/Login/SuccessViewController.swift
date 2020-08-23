//
//  SuccessViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class SuccessViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    var titleLabelText: String?
    var subtitleText: String?
    var doneHandler: (() -> Void)?
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset to allow all orientations
        AppUtility.lockOrientation(.all)
    }
    
    func setup() {
        // Sets up the text for the title and subtitle text
        self.titleLabel.text = titleLabelText
        self.subtitleLabel.text = subtitleText
    }
    
    // MARK: Actions
    @IBAction func doneButtonTapped(_ sender: Any) {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
        self.doneHandler?()
    }
    
}
