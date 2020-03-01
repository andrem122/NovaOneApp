//
//  ForgotViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/22/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class ForgotViewController: UIViewController {
    
    // MARK: Properties
    
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        // Do any additional setup after loading the view.
    }
    
    func setup() {
        self.title = "Password Reset"
    }
    
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        // Remove the modal popup view on touch of the cancel 'x' button
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
