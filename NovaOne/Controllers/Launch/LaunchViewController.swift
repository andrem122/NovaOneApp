//
//  ViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController, UIScrollViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var featurePageControl: UIPageControl!
    @IBOutlet weak var featureScrollView: UIScrollView!
    
    // Set Up slider content
    let featureOne: Dictionary = ["image": Defaults.Images.logo.rawValue, "title": "Welcome To NovaOne", "subText": "Automate your lead process today"]
    let featureTwo: Dictionary = ["image": Defaults.Images.logo.rawValue, "title": "24/7 Contact", "subText": "Find out how NovaOne works 24/7 to contact leads"]
    let featureThree: Dictionary = ["image": Defaults.Images.logo.rawValue, "title": "Mako's Adventures", "subText": "Eating dog biscuts and playing in dirt!"]
    var featureArray = [Dictionary <String,String>]()
    var timer: Timer?
    var featureViewIndex: Int = 0 // Start at 1 so slider can start sliding
    var featureViewWidth: CGFloat = CGFloat()
    var featureScrollViewContentSizeWidth: CGFloat = CGFloat()
    
    // MARK: Setup
    
    // Set up visual graphics
    func setup() {
        // Setup scroll view attributes and size
        self.featureArray = [self.featureOne, self.featureTwo, self.featureThree] // Set values to 'featureArray' here so we cant use the count property
        self.featureScrollView.isPagingEnabled = true
        
        self.featureScrollViewContentSizeWidth = self.view.bounds.width * CGFloat(self.featureArray.count)
        self.featureScrollView.contentSize = CGSize(width: self.featureScrollViewContentSizeWidth, height: 335) // height of scroll view must be equal to height of feature.xib file object to prevent vertical scrolling
        print("Scroll View Content Size Height: \(self.featureScrollView.contentSize.height)")
        
        self.featureScrollView.showsHorizontalScrollIndicator = false
        self.featureScrollView.delegate = self
        
        // Setup feature slides in scroll view
        for (index, feature) in self.featureArray.enumerated() {
            
            if let featureView = Bundle.main.loadNibNamed("Feature", owner: self, options: nil)?.first as? FeatureView {
                
                featureView.featureImage.image = UIImage(named: feature["image"]!)
                featureView.featureTitle.text = feature["title"]
                featureView.featureSubtext.text = feature["subText"]
                
                self.featureScrollView.addSubview(featureView)
                
                // Set featureView frame
                self.featureViewWidth = self.view.bounds.size.width
                featureView.frame.size.width = self.featureViewWidth
                featureView.frame.origin.x = CGFloat(index) * self.featureViewWidth // Set x position in the scroll view for each feature view in feature array
                featureView.frame.origin.y = self.view.bounds.origin.y + CGFloat(50)
                print("Feature View Height: \(featureView.frame.height)")
                
            }
            
        }
        
        // Set up page control
        self.featurePageControl.numberOfPages = self.featureArray.count
        self.featurePageControl.currentPage = 0
    }
    
    
    // Set up timer for automatic scrolling of slider
    func setUpTimer() {
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(changeSlides), userInfo: nil, repeats: true)
    }
    
    // Changes slides for the scroll view timer
    @objc func changeSlides() {
        
        // Scroll the scroll view by one slide each time
        //print("Feature View Index: \(self.featureViewIndex)")
        
        if self.featureViewIndex < self.featureArray.count - 1 {
           
            self.featureViewIndex += 1 // Set featureViewIndex to one because zero times anything is zero and will result waiting in another 3 seconds and the slider not sliding on the first timer count
           self.featureScrollView.setContentOffset(CGPoint(x: CGFloat(self.featureViewIndex) * self.featureViewWidth, y: 0), animated: true)
           
        } else {
            
            // Go back to the first slide and reset featureViewIndex when we reach the last slide
            self.featureScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.featureViewIndex = 0
            
        }
        
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Run set up functions after view loads
        self.setup()
        
    }
    
     // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Turn off timer after navigation to another view
        self.timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        // Rotate the orientation of the screen to potrait and lock it
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        
        // Set up timer again every time the view will appear
        // For example, if we navigate to the login view
        // and navigate back to the launch view, we want
        // to start the timer again to start the slider
        self.setUpTimer()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Reset lock orientation to all so that if naviagting to another view,
        // you can rotate the orientation again
        AppUtility.lockOrientation(.all)
    }
    

}

extension LaunchViewController {
    
    // Fired when the scroll view is done scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageNumber: CGFloat = scrollView.contentOffset.x / scrollView.frame.size.width // Example: 750 / 375 = page 2 or 1125 / 375 = page 3
        self.featurePageControl.currentPage = Int(pageNumber)
        self.featureViewIndex = Int(pageNumber) // Set featureView index equal to the page number obtained from manual scrolling so that the timer can start scrolling from the page the user stopped on
        
    }
    
    /* Function fired every time the user starts dragging scroll view.
       Turn off timer so the scroll view does not scroll every time the user
       begins to scroll the scroll view
    */
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        // Turn off timer to allow manual control of scroll view slider
        self.timer?.invalidate()
        
    }
    
    // Function fired every time the scroll view is done being dragged
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        // Reactivate the timer after user stops dragging the scroll view
        self.timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.changeSlides), userInfo: nil, repeats: true)
        
    }
    
}

