//
//  GlobalSplitViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/20/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class GlobalSplitViewController: UISplitViewController, UISplitViewControllerDelegate {

    override func viewDidLoad() {
      super.viewDidLoad()
      self.delegate = self
    }

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController: UIViewController!, ontoPrimaryViewController primaryViewController: UIViewController!) -> Bool{
      return true
    }

}
