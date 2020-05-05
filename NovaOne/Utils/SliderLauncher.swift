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
            Slide(title: "Mako's Adventures", subtitle: "This is a subtitle", imageName: "novaOneLogo"),
            Slide(title: "Welcome To NovaOne", subtitle: "Automate your lead process today!", imageName: "novaOneLogo"),
            Slide(title: "Welcome To Mako Land", subtitle: "Rah rah roo!", imageName: "novaOneLogo")
        ]
    }()
    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = .zero
        scrollView.backgroundColor = Defaults.novaOneColor
        scrollView.isPagingEnabled = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    var pageControl: UIPageControl
    var slideIndex: Int = 0
    var timer: Timer?
    var sliderDidEndLaunching = false
    
    init(pageControl: UIPageControl) {
        self.pageControl = pageControl
        super.init()
        self.setupScrollView()
    }

    convenience override init() {
        self.init(pageControl: UIPageControl()) // calls above mentioned controller with default view
    }
    
    func setupScrollView() {
        self.scrollView.delegate = self
    }
    
    func launchSlider() {
        // Sets up the scroll view, slides, and page control
        
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            window.addSubview(self.scrollView)
            
            // Setup the scroll view
            let scrollViewContentSize = window.frame.width * CGFloat(self.slides.count)
            self.scrollView.contentSize = CGSize(width: scrollViewContentSize, height: 335) // height of scroll view must be equal to height of feature.xib file object to prevent vertical scrolling
            self.scrollView.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: window.frame.height * 0.60)
            
            // Setup slides in scroll view
            for (index, slide) in self.slides.enumerated() {
                
                if let featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView {
                    
                    featureView.slide = slide
                    self.scrollView.addSubview(featureView)
                    
                    // Set featureView frame
                    featureView.frame = CGRect(x: CGFloat(index) * self.scrollView.frame.width, y: 0, width: self.scrollView.frame.width, height: self.scrollView.frame.height)
                }
                
            }
        }
        
        self.setUpSliderTimer()
        self.sliderDidEndLaunching = true
    }
    
    func setUpSliderTimer() {
        print("Timer enabled")
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
    func disableTimer() {
        print("Timer disabled")
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
        print("TIMER INVALIDATED")
        self.timer?.invalidate()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        // Function fired every time the scroll view is done being dragged
        // Reactivate the timer after user stops dragging the scroll view
        print("TIMER REACTIVATED")
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
}
