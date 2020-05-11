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
    @IBOutlet weak var scrollView: UIScrollView!
    lazy var sliderLauncher = SliderLauncher(scrollView: self.scrollView, pageControl: self.pageControl)

    override func viewDidLoad() {
        super.viewDidLoad()
        changeStyleForInterfaceStyle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Rotate the orientation of the screen to potrait and lock it
        //AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        sliderLauncher.launchSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset lock orientation to all so that if naviagting to another view,
        // you can rotate the orientation again
        //AppUtility.lockOrientation(.all)
        sliderLauncher.disableTimer()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.changeStyleForInterfaceStyle()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) {
            [weak self] (_) in
            self?.sliderLauncher.repositionSlideOnDeviceRotation()
        }
    }
    
    func changeStyleForInterfaceStyle() {
        // Changes the style of elements based on the interface style
        if self.traitCollection.userInterfaceStyle == .dark {
            // User Interface is Dark
            self.pageControl.currentPageIndicatorTintColor = .white
        } else {
            // User Interface is Light
            self.pageControl.currentPageIndicatorTintColor = .black
        }
    }
    

}

