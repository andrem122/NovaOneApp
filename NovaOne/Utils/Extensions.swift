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
