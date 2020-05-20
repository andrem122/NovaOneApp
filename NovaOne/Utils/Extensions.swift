//
//  Extensions.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/1/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

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
    
    func addBorders(edges: UIRectEdge = .all, color: UIColor = .black, width: CGFloat = 1.0) {
       
        func createBorder() -> UIView {
            let borderView = UIView(frame: CGRect.zero)
            borderView.translatesAutoresizingMaskIntoConstraints = false
            borderView.backgroundColor = color
            return borderView
        }

        if (edges.contains(.all) || edges.contains(.top)) {
            let topBorder = createBorder()
            self.addSubview(topBorder)
            NSLayoutConstraint.activate([
                topBorder.topAnchor.constraint(equalTo: self.topAnchor),
                topBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                topBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                topBorder.heightAnchor.constraint(equalToConstant: width)
            ])
        }
        if (edges.contains(.all) || edges.contains(.left)) {
            let leftBorder = createBorder()
            self.addSubview(leftBorder)
            NSLayoutConstraint.activate([
                leftBorder.topAnchor.constraint(equalTo: self.topAnchor),
                leftBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                leftBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                leftBorder.widthAnchor.constraint(equalToConstant: width)
                ])
        }
        if (edges.contains(.all) || edges.contains(.right)) {
            let rightBorder = createBorder()
            self.addSubview(rightBorder)
            NSLayoutConstraint.activate([
                rightBorder.topAnchor.constraint(equalTo: self.topAnchor),
                rightBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                rightBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                rightBorder.widthAnchor.constraint(equalToConstant: width)
                ])
        }
        if (edges.contains(.all) || edges.contains(.bottom)) {
            let bottomBorder = createBorder()
            self.addSubview(bottomBorder)
            NSLayoutConstraint.activate([
                bottomBorder.bottomAnchor.constraint(equalTo: self.bottomAnchor),
                bottomBorder.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                bottomBorder.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                bottomBorder.heightAnchor.constraint(equalToConstant: width)
            ])
        }
    }
}

var vSpinner: UIView? // Global variable, must set to nil when done using to avoid memory leak
extension UIViewController {
    func getSizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        // Returns the horizontal and vertical size class in a tuple
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }
    
    func showSpinner(for view: UIView, textForLabel: String?) {
        // Shows a spinner/loading icon for the current view
        
        // Create a view that has the same CGRect dimensions as the parent view
        let spinnerView = UIView.init(frame: view.bounds)
        spinnerView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        
        // Create the spinner that goes in the center of the spinner view
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.center = spinnerView.center
        
        // Create label to go underneath spinner
        if textForLabel != nil {
            let label = UILabel()
            label.frame.size = CGSize(width: spinnerView.bounds.width, height: 30) // Set width and height so label is visible
            label.center = CGPoint(x: spinnerView.center.x, y: spinnerView.center.y + 25) // Set position on spinnerView
            guard let text = textForLabel else { return }
            label.text = text
            label.textColor = .lightGray
            label.textAlignment = .center
            label.font.withSize(15)
            spinnerView.addSubview(label)
        }
        
        // Add subviews
        spinnerView.addSubview(spinner)
        view.addSubview(spinnerView)
        
        vSpinner = spinnerView
        
    }
    
    func removeSpinner() {
        // Removes the spinner from the view it is embedded in and deallocates it from memory
        DispatchQueue.main.async {
            vSpinner?.removeFromSuperview()
            vSpinner = nil
        }
    }
}

extension String {
    var isAlphabetical: Bool {
        // Returns false or true if the string has only alphabetical characters
        return !self.isEmpty && self.range(of: "[^a-zA-Z]", options: .regularExpression) == nil
    }
    
    var isNumeric: Bool {
        // Returns true if string is a number and false if it is not
        return Int(self) != nil
    }
    
    func trim() -> String {
        // Removes any leading and trailing white space for strings
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}

extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        // Centers map to a location so it's visible to the user and the zoom level is adequate and adds an annotation to the map
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        self.setRegion(coordinateRegion, animated: true)
        
        // Add an annotation to the map
        let locationMarker = MKPointAnnotation()
        locationMarker.title = ""
        locationMarker.coordinate = location.coordinate
        self.addAnnotation(locationMarker)
        
    }
    
    func removeAllAnnotations() {
        // Removes all previously added annotations
        for annotation in self.annotations {
            self.removeAnnotation(annotation)
        }
    }
}
