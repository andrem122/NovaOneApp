//
//  AddCompanyStreetViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class AddCompanyAddressViewController: AddCompanyBaseViewController, AddAddress {
    
    // MARK: Properties
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var mapView: MKMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    lazy var filter: GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "US"
        return filter
    }()
    
    func setupMapView() {
        self.mapView.delegate = self
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.isScrollEnabled = false
        self.mapView.isUserInteractionEnabled = false
        self.mapView.isHidden = true
    }
    
    func presentAutocomplete(textForSearchBar: String) {
        // Sets up and shows the autocomplete view controller
        
        // Setup results view controller
        self.resultsViewController = GMSAutocompleteResultsViewController()
        //self.resultsViewController?.view.backgroundColor = UIColor(named: "googleSearchBackgroundColor")
        self.resultsViewController?.delegate = self
        
        // Bias search results with a filter
        print("setting up filter")
        self.resultsViewController?.autocompleteFilter = self.filter
        
        // Setup search controller
        self.searchController = UISearchController()
        //self.searchController?.view.backgroundColor = UIColor(named: "googleSearchBackgroundColor")
        self.searchController?.searchResultsUpdater = self.resultsViewController
        
        // Add the search bar to the right of the nav bar,
        // use a popover to display the results.
        // Set an explicit size as we don't want to use the entire nav bar.
        self.resultsViewController?.view.addSubview((self.searchController?.searchBar)!)
        self.resultsViewController?.view.translatesAutoresizingMaskIntoConstraints = false
        self.searchController?.searchBar.sizeToFit()
        self.searchController?.searchBar.text = textForSearchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        self.definesPresentationContext = true
        
        // Keep the navigation bar visible.
        self.searchController?.obscuresBackgroundDuringPresentation = false
        searchController?.modalPresentationStyle = .fullScreen
        
        guard let resultsViewController = self.resultsViewController else { return }
        self.present(resultsViewController, animated: true) {
            DispatchQueue.main.async {
                [weak self] in
                self?.mapView.removeAllAnnotations()
                self?.searchController?.searchBar.becomeFirstResponder()
            }
        }
    }
    
    func setupTextField() {
        self.addressTextField.delegate = self
        self.addressTextField.clearButtonMode = .always
    }
    
    func setupContinueButton() {
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContinueButton()
        self.setupTextField()
        self.setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.addressTextField.becomeFirstResponder()
    }
    
    
    // MARK: Actions
    @IBAction func addressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.addressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let address = self.addressTextField.text else { return }
        if address.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Address Required", body: "Please type in an address.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let addCompanyEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addCompanyEmail.rawValue) as? AddCompanyEmailViewController else { return }
            
            // Pass company object to next view controller
            addCompanyEmailViewController.company = self.company
            addCompanyEmailViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addCompanyEmailViewController, animated: true)
        }
    }
    
}

extension AddCompanyAddressViewController {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
        self.dismiss(animated: true) {
            [weak self] in
            
            guard
                let addressComponents = place.addressComponents,
                let address = place.formattedAddress,
                let continueButton = self?.continueButton
            else { return }
            
            // Enable button
            UIHelper.enable(button: continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            
            // Set text for address field
            self?.addressTextField.text = address
            self?.addressTextField.resignFirstResponder()
            
            // Set location for map view
            let latitude = place.coordinate.latitude
            let longitude = place.coordinate.longitude
            let selectedLocation = CLLocation(latitude: latitude, longitude: longitude)
            self?.mapView.centerToLocation(selectedLocation)
            self?.mapView.isHidden = false
            
            // Get street address, city, state, and zip from the place the user selected
            self?.company?.address = address
            for component in addressComponents {
                
                let componentType = component.types[0]
                if componentType == Defaults.GooglePlaceAddressComponents.city.rawValue { // City
                    self?.company?.city = component.name
                } else if componentType == Defaults.GooglePlaceAddressComponents.state.rawValue { // State
                    guard let state = component.shortName else { return }
                    self?.company?.state = state
                } else if componentType == Defaults.GooglePlaceAddressComponents.zip.rawValue { // Zip code
                    self?.company?.zip = component.name
                }
                
            }
            
        }
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: ", error.localizedDescription)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            self.presentAutocomplete(textForSearchBar: string)
        }
        return true
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // Set a view for each annotation
        guard annotation is MKPointAnnotation else { return nil }
        
        let reuseIdentifier = "annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
        
    }
}
