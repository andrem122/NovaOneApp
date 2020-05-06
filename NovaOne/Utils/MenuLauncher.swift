//
//  MenuLauncher.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class MenuOption: NSObject {
    // A model class to represent each item/cell in the menu
    
    let name: String
    let imageName: String
    
    init(name: String, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}

class MenuLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    let cellReuseIdentifier: String = "menuCell"
    var menuOpen: Bool = false
    let menuOptions: [MenuOption] = {
        return [
        MenuOption(name: "Home", imageName: "house"),
        MenuOption(name: "Appointments", imageName: "calendar"),
        MenuOption(name: "Leads", imageName: "person"),
        MenuOption(name: "Companies", imageName: "briefcase"),
        MenuOption(name: "Account", imageName: "gear")]
    }()
    
    override init() {
        super.init()
        self.setupCollectionView()
    }
    
    func setupCollectionView() {
        // Setup the collection view
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: self.cellReuseIdentifier)
    }
    
    func toggleMenu() {
        // Shows the menu
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            // Add menu view to the window
            window.addSubview(self.collectionView)
            
            let collectionViewWidth = window.frame.width / 3 // Make menu half the window
            let collectionViewHeight = window.frame.height
            
            // Set up a shadow around the menu so we can see it easier
            self.collectionView.layer.shadowColor = UIColor.black.cgColor
            self.collectionView.layer.shadowRadius = 5
            self.collectionView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
            //self.collectionView.layer.shouldRasterize = true
            self.collectionView.layer.masksToBounds = false
            
            if self.menuOpen == false {
                // Opening the menu
                let collectionViewClosedFrame = CGRect(x: -collectionViewWidth, y: 0, width: collectionViewWidth, height: collectionViewHeight)
                self.collectionView.frame = collectionViewClosedFrame
                self.collectionView.layer.shadowOpacity = 0.5 // Show shadow of menu before it is animated open
                
                let collectionViewOpenFrame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
                
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.frame = collectionViewOpenFrame
                }) { [weak self] (success) in
                    self?.collectionView.layer.shadowPath = UIBezierPath(rect: collectionViewOpenFrame).cgPath
                    self?.menuOpen = true
                }
                
            } else {
                // Closing the menu
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.layer.shadowOpacity = 0 // Animate shadow to fade away with the sliding in of the menu
                    self.collectionView.frame = CGRect(x: -collectionViewWidth, y: 0, width: collectionViewWidth, height: collectionViewHeight)
                }, completion: nil)
                
                self.menuOpen = false
                
            }
        }
    }
}

extension MenuLauncher {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.menuOptions.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier, for: indexPath) as! MenuCollectionViewCell
        let menuOption = self.menuOptions[indexPath.row]
        cell.menuOption = menuOption
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set size of each cell in the collection view
        return CGSize(width: self.collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
   
}
