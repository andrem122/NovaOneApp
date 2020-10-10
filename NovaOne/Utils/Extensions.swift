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

extension UIViewController {
    func getSizeClass() -> (UIUserInterfaceSizeClass, UIUserInterfaceSizeClass) {
        // Returns the horizontal and vertical size class in a tuple
        return (self.traitCollection.horizontalSizeClass, self.traitCollection.verticalSizeClass)
    }
    
    func showSpinner(for view: UIView, textForLabel: String?) -> UIView {
        // Shows a spinner/loading icon for the current view
        
        // Create a view that has the same CGRect dimensions as the parent view
        let spinnerView = UIView.init(frame: view.bounds)
        view.addSubview(spinnerView)
        spinnerView.backgroundColor = UIColor(named: Defaults.Colors.view.rawValue)
        
        // Create the spinner that goes in the center of the spinner view
        let spinner = UIActivityIndicatorView(style: .medium)
        spinnerView.addSubview(spinner)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = UIColor(named: Defaults.Colors.textField.rawValue)
        
        // Add constraints
        var xConstraint = NSLayoutConstraint(item: spinner, attribute: .centerX, relatedBy: .equal, toItem: spinnerView, attribute: .centerX, multiplier: 1, constant: 0)
        var yConstraint = NSLayoutConstraint(item: spinner, attribute: .centerY, relatedBy: .equal, toItem: spinnerView, attribute: .centerY, multiplier: 1, constant: 0)
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        
        // Create label to go underneath spinner
        if textForLabel != nil {
            let label = UILabel()
            spinnerView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.frame.size = CGSize(width: spinnerView.bounds.width, height: 30) // Set width and height so label is visible
            
            // Add constraints
            xConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: spinnerView, attribute: .centerX, multiplier: 1, constant: 0)
            yConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: spinnerView, attribute: .centerY, multiplier: 1, constant: 25)
            NSLayoutConstraint.activate([xConstraint, yConstraint])
            
            guard let text = textForLabel else { return UIView() }
            label.text = text
            label.textColor = UIColor(named: Defaults.Colors.textField.rawValue)
            label.textAlignment = .center
            label.font.withSize(15)
        }
        
        return spinnerView
        
    }
    
    func removeSpinner(spinnerView: UIView) {
        // Removes the spinner from the view it is embedded in and deallocates it from memory
        DispatchQueue.main.async {
            spinnerView.removeFromSuperview()
        }
    }
    
    func resetNotificationCount(for index: Int) {
        // Make HTTP requst to server to notification counts to zero
        // in the server database
        var updateColumn = ""
        switch index {
            case 0:
                updateColumn = "application_badge_count"
            case 1:
                updateColumn = "new_appointment_count"
            case 2:
                updateColumn = "new_lead_count"
            default:
                updateColumn = ""
        }
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerEmail = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
            print("could not get customer object - HomeTabBarController")
            return
        }
        
        let parameters: [String: Any] = [
            "customerUserId": customer.id,
            "email": customerEmail,
            "password": password,
            "updateColumn": updateColumn,
        ]
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/resetNotificationCounts.php", dataModel: SuccessResponse.self, parameters: parameters) { (result) in
            switch result {
                case .success(let successResponse):
                    print("Notification counts successfully reset in database: \(successResponse.successReason)")
                case .failure(let error):
                    print("Failed to reset notification counts: \(error.localizedDescription)")
            }
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
    
    var isPhoneNumber: Bool {
        do {
            let detector = try NSDataDetector(types: NSTextCheckingResult.CheckingType.phoneNumber.rawValue)
            let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
            if let res = matches.first {
                return res.resultType == .phoneNumber && res.range.location == 0 && res.range.length == self.count
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    func trim() -> String {
        // Removes any leading and trailing white space for strings
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    func addingPercentEncodingForRFC3986() -> String? {
        // Percent encodes strings
        let unreserved = "-._~/?"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
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

extension Notification.Name {
  static let newLeadFetched = Notification.Name("com.novaonesoftware.NovaOne.newLeadsFetched")
}
