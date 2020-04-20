//
//  EmptyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class EmptyViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    var titleLabelText: String?
    var parentViewContainerController: UIViewController? // The container view that this view is embedded in
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTitle()
    }
    
    func setupTitle() {
        // Sets the text for the title label
        self.titleLabel.text = self.titleLabelText
    }
    
    // MARK: Actions
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        if let leadsContainerViewController = self.parentViewContainerController as? LeadsContainerViewController {
            leadsContainerViewController.containerView.subviews[0].removeFromSuperview() // Remove empty state view controller from container view
            leadsContainerViewController.viewDidLoad() // Reload view did load to check for new objects
        } else if let appointmentsContainerViewController = self.parentViewContainerController as? AppointmentsContainerViewController {
            appointmentsContainerViewController.containerView.subviews[0].removeFromSuperview()
            appointmentsContainerViewController.viewDidLoad()
        }
        
    }
    
}
