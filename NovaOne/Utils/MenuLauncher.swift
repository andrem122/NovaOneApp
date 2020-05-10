//
//  MenuLauncher.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

enum MenuOptionNames: String {
    case home = "Home"
    case appointments = "Appointments"
    case leads = "Leads"
    case companies = "Companies"
    case account = "Account"
}

class MenuOption: NSObject {
    // A model class to represent each item/cell in the menu
    
    let name: String
    let enumMenuOption: MenuOptionNames
    let imageName: String
    
    init(name: String, enumMenuOption: MenuOptionNames, imageName: String) {
        self.name = name
        self.enumMenuOption = enumMenuOption
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
    var homeTabBarController: HomeTabBarController
    let menuWidth: CGFloat = 250
    let menuOptions: [MenuOption] = {
        return [
        MenuOption(name: MenuOptionNames.home.rawValue, enumMenuOption: .home, imageName: "house"),
        MenuOption(name: MenuOptionNames.appointments.rawValue, enumMenuOption: .appointments, imageName: "calendar"),
        MenuOption(name: MenuOptionNames.leads.rawValue, enumMenuOption: .leads, imageName: "person"),
        MenuOption(name: MenuOptionNames.companies.rawValue, enumMenuOption: .companies, imageName: "briefcase"),
        MenuOption(name: MenuOptionNames.account.rawValue, enumMenuOption: .account, imageName: "gear")]
    }()
    var menuLeadingConstraint: NSLayoutConstraint?
    
    init(homeTabBarController: HomeTabBarController) {
        self.homeTabBarController = homeTabBarController
        super.init()
        self.setupCollectionView()
    }

    convenience override init() {
        self.init(homeTabBarController: HomeTabBarController()) // calls above mentioned controller with default view
    }
    
    func setupCollectionView() {
        // Setup the collection view
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.register(MenuCollectionViewCell.self, forCellWithReuseIdentifier: self.cellReuseIdentifier)
    }
    
    func toggleMenu(completion: (() -> Void)?) {
        // Shows the menu
        if let window = UIApplication.shared.windows.filter({$0.isKeyWindow}).first {
            
            // Add menu view to the window
            window.addSubview(self.collectionView)
            
            // Add constraints to menu if we haven't already added them when the menu was toggled
            if self.collectionView.constraints.count == 0 {
                let topConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: window, attribute: .top, multiplier: 1, constant: 0)
                let bottomConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: 0)
                self.menuLeadingConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: window.safeAreaLayoutGuide, attribute: .leading, multiplier: 1, constant: -self.menuWidth)
                let widthConstraint = NSLayoutConstraint(item: self.collectionView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: self.menuWidth)
                NSLayoutConstraint.activate([topConstraint, bottomConstraint, self.menuLeadingConstraint!, widthConstraint])
            }
            
            // Set up a shadow around the menu so we can see it easier
            self.collectionView.layer.shadowColor = UIColor.black.cgColor
            self.collectionView.layer.shadowRadius = 5
            self.collectionView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
            //self.collectionView.layer.shouldRasterize = true
            self.collectionView.layer.masksToBounds = false
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false

            if self.menuOpen == false {
                // Opening the menu
                self.menuLeadingConstraint?.constant = 0

                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.layer.shadowOpacity = 0.5 // Show shadow of menu before it is animated open
                    window.layoutIfNeeded()
                }) {(success) in
                    guard let unwrappedCompletion = completion else { return }
                    unwrappedCompletion()
                }
                self.menuOpen = true
                
            } else {
                // Closing the menu
                self.menuLeadingConstraint?.constant = -self.menuWidth
                UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                    self.collectionView.layer.shadowOpacity = 0 // Animate shadow to fade away with the sliding in of the menu
                    window.layoutIfNeeded()
                }) {(success) in
                    guard let unwrappedCompletion = completion else { return }
                    unwrappedCompletion()
                }
                
                self.menuOpen = false
            }
            
            guard let menuLeadingConstraint = self.menuLeadingConstraint else { return }
            print("Menu Leading Constraint Value: \(menuLeadingConstraint.constant)")
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.toggleMenu {
            [weak self] in
            guard let menuOption = self?.menuOptions[indexPath.item] else { return }
            self?.homeTabBarController.showViewForMenuOptionSelected(menuOption: menuOption)
        }
        
    }
   
}
