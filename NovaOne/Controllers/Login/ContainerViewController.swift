//
//  ContainerViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewContainerLeadingConstraint: NSLayoutConstraint!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.alterContainerViewWidth()
    }
    
    func alterContainerViewWidth() {
        // Detects the size class and makes the container view
        // half the superview's size if size class is width and height of regular
        switch self.getSizeClass() {
            
        case (.unspecified, .unspecified):
            print("Unknown")
        case (.unspecified, .compact):
            print("Unknown width, compact height")
        case (.unspecified, .regular):
            print("Unknown width, regular height")
        case (.compact, .unspecified):
            print("Compact width, unknown height")
        case (.regular, .unspecified):
            print("Regular width, unknown height")
        case (.regular, .compact):
            print("Regular width, compact height")
        case (.compact, .compact):
            print("Compact width, compact height")
        case (.regular, .regular):
            print("Regular width, regular height")
            self.viewContainerLeadingConstraint.constant = self.view.frame.width / 3
            self.view.layoutIfNeeded()
        case (.compact, .regular):
            print("Compact width, regular height")
        case (_, _):
            print("None")
            
        }
        
    }
    
    // MARK: Actions
    

}
