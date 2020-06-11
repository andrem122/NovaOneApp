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
    @IBOutlet weak var addObjectButton: NovaOneButton!
    var addObjectButtonTitle: String?
    var addObjectButtonHandler: (() -> Void)?
    var titleLabelText: String?
    var parentViewContainerController: UIViewController? // The container view that this view is embedded in
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTitles()
    }
    
    func setupTitles() {
        // Sets the text for the title label
        self.titleLabel.text = self.titleLabelText
        
        guard let addObjectButtonTitle = self.addObjectButtonTitle else { print("unable to set button title"); return }
        self.addObjectButton.setTitle(addObjectButtonTitle, for: .normal)
    }
    
    // MARK: Actions
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        if let leadsContainerViewController = self.parentViewContainerController as? LeadsContainerViewController {
            leadsContainerViewController.containerView.subviews.first?.removeFromSuperview() // Remove empty state view controller from container view
            leadsContainerViewController.viewDidLoad() // Reload view did load to check for new objects
        } else if let appointmentsContainerViewController = self.parentViewContainerController as? AppointmentsContainerViewController {
            appointmentsContainerViewController.containerView.subviews.first?.removeFromSuperview()
            appointmentsContainerViewController.viewDidLoad()
        } else if let companiesContainerViewController = self.parentViewContainerController as? CompaniesContainerViewController {
            companiesContainerViewController.containerView.subviews.first?.removeFromSuperview()
            companiesContainerViewController.viewDidLoad()
        }
        
    }
    
    @IBAction func addObjectButtonTapped(_ sender: Any) {
        // Call the handler function for the add object button
        self.addObjectButtonHandler?()
    }
    
}
