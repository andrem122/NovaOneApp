//
//  SliderLauncher.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/3/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class Slide: NSObject {
    
    var title: String
    var subtitle: String
    var imageName: String
    
    init(title: String, subtitle: String, imageName: String) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
    }
}

class SliderLauncher: NSObject {
    
    let slides: [Slide] = {
        return [
            Slide(title: "Welcome To NovaOne", subtitle: "Automate your lead process today!", imageName: "novaOneLogoSlider"),
            Slide(title: "24/7 Contact", subtitle: "NovaOne works 24/7 to contact and qualify leads", imageName: "texting"),
            Slide(title: "Auto Appointments", subtitle: "NovaOne makes it easy to set up appointments with leads", imageName: "interface")
        ]
    }()
    var pageControl: UIPageControl
    var scrollView: UIScrollView
    var slideIndex: Int = 0
    var timer: Timer?
    var sliderDidEndLaunching = false
    
    init(scrollView: UIScrollView, pageControl: UIPageControl) {
        self.pageControl = pageControl
        self.scrollView = scrollView
        super.init()
        self.setupScrollView()
    }

    convenience override init() {
        self.init(scrollView: UIScrollView(), pageControl: UIPageControl()) // calls above mentioned controller with default view
    }
    
    func setupScrollView() {
        self.scrollView.delegate = self
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.showsVerticalScrollIndicator = false
    }
    
    func launchSlider() {
        // Sets up the scroll view, slides, and page control
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            // Setup the scroll view
            let scrollViewContentSize = window.bounds.width * CGFloat(self.slides.count)
            self.scrollView.contentSize = CGSize(width: scrollViewContentSize, height: self.scrollView.bounds.height)
            
            // Setup slides in scroll view
            var nextSlideLeadingConstraint = self.scrollView.leftAnchor
            for (index, slide) in self.slides.enumerated() {
                
                if let featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView {
                    
                    featureView.slide = slide
                    featureView.translatesAutoresizingMaskIntoConstraints = false
                    self.scrollView.addSubview(featureView)
                    
                    // Set constraints
                    NSLayoutConstraint.activate([
                        featureView.leftAnchor.constraint(equalTo: nextSlideLeadingConstraint),
                        featureView.centerYAnchor.constraint(equalTo: self.scrollView.centerYAnchor),
                        featureView.widthAnchor.constraint(equalTo: self.scrollView.widthAnchor),
                        featureView.heightAnchor.constraint(equalTo: self.scrollView.heightAnchor),
                    ])
                    
                    nextSlideLeadingConstraint = featureView.rightAnchor
                    
                    // Set last slide right anchor
                    if index == slides.count - 1 {
                        NSLayoutConstraint.activate([
                            featureView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor)
                        ])
                    }
                    
                }
                
            }
            
        }
        
        self.setUpSliderTimer()
        self.sliderDidEndLaunching = true
    }
    
    func setUpSliderTimer() {
        print("Setting up a timer")
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        self.timer?.invalidate()
    }
    
    @objc func changeSlides() {
        // Changes slides for the scroll view timer one slide at a time
        if self.slideIndex < self.slides.count - 1 {
            self.slideIndex += 1 // Set featureViewIndex to one because zero times anything is zero and will result waiting in another 3 seconds and the slider not sliding on the first timer count
            
            self.scrollView.setContentOffset(CGPoint(x: CGFloat(self.slideIndex) * scrollView.frame.width, y: 0), animated: true)
           
        } else {
            
            // Go back to the first slide and reset featureViewIndex when we reach the last slide
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.slideIndex = 0
            
        }
        
        print("Slide Index: \(self.slideIndex)")
        
        
    }
    
    func repositionSlideOnDeviceRotation() {
        // Changes slides for the scroll view when the device changes orientation
        self.disableTimer()
        
        let xPosition = CGFloat(self.slideIndex) * self.scrollView.frame.width
        self.scrollView.setContentOffset(CGPoint(x: xPosition, y: 0), animated: true)
        
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
}

extension SliderLauncher: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Fired when the scroll view is done scrolling
        if sliderDidEndLaunching {
            let pageNumber: CGFloat = scrollView.contentOffset.x / scrollView.frame.size.width // Example: 750 / 375 = page 2 or 1125 / 375 = page 3
            self.pageControl.currentPage = Int(pageNumber)
            self.slideIndex = Int(pageNumber) // Set featureView index equal to the page number obtained from manual scrolling so that the timer can start scrolling from the page the user stopped on
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        /* Function fired every time the user starts dragging scroll view.
           Turn off timer so the scroll view does not scroll every time the user
           begins to scroll the scroll view
        */
        self.timer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Function fired every time the scroll view is done being dragged
        // Reactivate the timer after user stops dragging the scroll view
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
}
