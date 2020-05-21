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
    var sliderLauncher: SliderLauncher?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.changeStyleForInterfaceStyle()
        self.setupPageControlForRegularSizeClass()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.sliderLauncher = SliderLauncher(scrollView: self.scrollView, pageControl: self.pageControl)
        self.sliderLauncher?.launchSlider()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sliderLauncher?.disableTimer()
        sliderLauncher = nil // Deallocate from memory to prevent slider timer from running
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        self.changeStyleForInterfaceStyle()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) {
            [weak self] (_) in
            self?.sliderLauncher?.repositionSlideOnDeviceRotation()
        }
    }
    
    func setupPageControlForRegularSizeClass() {
        // Sets up the page control for the regular width & height size class
        if self.traitCollection.horizontalSizeClass == .regular && self.traitCollection.verticalSizeClass == .regular {
            // Change size of page control dots for ipads
            self.pageControl.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
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

