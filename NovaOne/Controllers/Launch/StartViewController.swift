//
//  ViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class StartViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    lazy var sliderLauncher = SliderLauncher(pageControl: self.pageControl)

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Rotate the orientation of the screen to potrait and lock it
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        sliderLauncher.launchSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset lock orientation to all so that if naviagting to another view,
        // you can rotate the orientation again
        AppUtility.lockOrientation(.all)
        sliderLauncher.disableTimer()
    }
    

}

