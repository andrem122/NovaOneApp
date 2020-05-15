//
//  Extensions.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import GooglePlaces

extension UIView {
    func addConstraints(with format: String, views: UIView...) {
        // Adds constraints to views through a visual string format
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
}

extension UIViewController {
    func getSizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        // Returns the horizontal and vertical size class in a tuple
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }
}

extension String {
    var isAlphabetical: Bool {
        // Returns false or true if the string has only alphabetical characters
        return !self.isEmpty && self.range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    func trim() -> String {
        // Removes any leading and trailing white space for strings
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
