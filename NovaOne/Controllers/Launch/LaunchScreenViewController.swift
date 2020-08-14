//
//  LaunchScreenViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LaunchScreenViewController: UIViewController {
    
    // MARK: Properties
    @IBOutlet weak var novaOneLogo: UIImageView!
    let novaOneLogoImage: UIImageView = UIImageView(image: UIImage(named: Defaults.Images.novaOneLogoVertical.rawValue))
    let splashView: UIView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupSplashView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.moveRocket()
        }
    }
    
    func setupSplashView() {
        // Sets up the splash view
        
        self.splashView.backgroundColor = Defaults.novaOneColor
        self.view.addSubview(self.splashView)
        self.splashView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        
        self.novaOneLogoImage.contentMode = .scaleAspectFit
        splashView.addSubview(self.novaOneLogoImage)
        
        self.novaOneLogoImage.frame = CGRect(x: self.splashView.frame.midX - 85, y: self.splashView.frame.midY - 85, width: 170, height: 170)
        
    }
    
    func moveRocket() {
        // Moves the rocket by animating it
        
        UIView.animate(withDuration: 2, animations: {
            self.novaOneLogoImage.frame = CGRect(x: self.splashView.frame.midX - 85, y: self.splashView.frame.midY - 300, width: 170, height: 170)
        }) { (success) in
            self.navigateToNextScreen()
        }
        
    }
    
    func isLoggedin() -> Bool {
        // Checks whether or not the user is logged in
        return UserDefaults.standard.bool(forKey: Defaults.UserDefaults.isLoggedIn.rawValue) // Returns false by default if no key is found
    }
    
    func navigateToNextScreen() {
        // Goes to the start screen or login screen view controller based on whether or not the user is logged in
        if self.isLoggedin() == true {
            // Get container view controller
            guard let containerViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.container.rawValue) as? ContainerViewController else { return }
            
            // Present container view controller
            containerViewController.modalPresentationStyle = .fullScreen // Set presentaion style of view to full screen
            self.present(containerViewController, animated: true, completion: nil)
        } else {
            guard let startViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.start.rawValue) as? StartViewController else { return }
            self.present(startViewController, animated: true, completion: nil)
        }
        
    }

}
