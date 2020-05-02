//
//  MenuLauncher.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class MenuLauncher: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: Properties
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        return collectionView
    }()
    let cellReuseIdentifier: String = "menuCell"
    
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
    
    func showMenu() {
        // Shows the menu
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            window.addSubview(self.collectionView)
            
            let collectionViewWidth = window.frame.width / 2 // Make menu half the window
            let collectionViewHeight = window.frame.height
            self.collectionView.frame = CGRect(x: -collectionViewWidth, y: 0, width: collectionViewWidth, height: collectionViewHeight)
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.collectionView.frame = CGRect(x: 0, y: 0, width: collectionViewWidth, height: collectionViewHeight)
            }, completion: nil)
        }
    }
    
    func hideMenu() {
        // Removes the menu
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            let collectionViewHeight = window.frame.height
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.collectionView.frame = CGRect(x: 0, y: 0, width: 0, height: collectionViewHeight)
            }, completion: nil)
            
        }
    }
}

extension MenuLauncher {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: self.cellReuseIdentifier, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Set size of each cell in the collection view
        return CGSize(width: collectionView.frame.width, height: 50)
    }
   
}
