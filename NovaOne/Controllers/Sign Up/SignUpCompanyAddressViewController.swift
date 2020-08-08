//
//  SignUpAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import GooglePlaces
import MapKit

class SignUpCompanyAddressViewController: BaseSignUpViewController, AddAddress {
    
    // MARK: Properties
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    @IBOutlet weak var mapView: MKMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    lazy var filter: GMSAutocompleteFilter = {
        let filter = GMSAutocompleteFilter()
        filter.type = .address
        filter.country = "US"
        return filter
    }()
    
    // For state restortation
    var continuationActivity: NSUserActivity {
        let activity = NSUserActivity(activityType: AppState.UserActivities.signup.rawValue)
        activity.persistentIdentifier = Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue
        activity.isEligibleForHandoff = true
        activity.title = Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue
        
        let textFieldText = self.addressTextField.text
        let continueButtonState = textFieldText?.isEmpty ?? true ? false : true
        
        let userInfo = [AppState.UserActivityKeys.signup.rawValue: textFieldText as Any,
                                       AppState.activityViewControllerIdentifierKey: Defaults.ViewControllerIdentifiers.signUpCompanyAddress.rawValue as Any, AppState.UserActivityKeys.signupButtonEnabled.rawValue: continueButtonState as Any]
        
        activity.addUserInfoEntries(from: userInfo)
        activity.becomeCurrent()
        return activity
    }
    
    // MARK: Methods
    func continueFrom(activity: NSUserActivity) {
        // Restore the view controller to its previous state using the activity object plugged in from scene delegate method scene(_:willConnectTo:options:)
        let restoreText = activity.userInfo?[AppState.UserActivityKeys.signup.rawValue] as? String
        let continueButtonIsEnabled = activity.userInfo?[AppState.UserActivityKeys.signupButtonEnabled.rawValue] as? Bool
        self.restoreText = restoreText
        self.restoreContinueButtonState = continueButtonIsEnabled
    }
    
    func setup() {
        // General setup
        
        // State restoration
        if self.restoreText != nil && self.restoreContinueButtonState != nil {
            // Restore text
            self.addressTextField.text = self.restoreText
            
            // Restore button state
            guard let continueButtonState = self.restoreContinueButtonState else { return }
            if continueButtonState == true {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            } else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            }
            
        } else {
            // Get data from coredata if it is available and fill in the field if no state restoration text exists
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCustomerObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
                print("could not get coredata company object - SignUpCompanyAddressViewController")
                return
            }
            guard let address = coreDataCustomerObject.address else { print("could not get core data company address - SignUpCompanyAddressViewController"); return }
            self.addressTextField.text = address
            
            // Enable the continue button
            if address.isEmpty {
                UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false)
            } else {
                UIHelper.enable(button: self.continueButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
        self.setupTextField()
        self.setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.addressTextField.becomeFirstResponder()
    }
    
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
    
    // MARK: Actions
    @IBAction func continueButtonTapped(_ sender: Any) {
        
        guard let address = self.addressTextField.text else { return }
        if address.isEmpty {
            let popUpOkViewController = self.alertService.popUpOk(title: "Address Required", body: "Please type in an address.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        } else {
            guard let signUpCompanyEmailViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCompanyEmail.rawValue) as? SignUpCompanyEmailViewController else { return }
            
            // Pass customer and company object to next view controller
            signUpCompanyEmailViewController.customer = self.customer
            signUpCompanyEmailViewController.company = self.company
            
            // Get existing core data object and update it
            let filter = NSPredicate(format: "id == %@", "0")
            guard let coreDataCompanyObject = PersistenceService.fetchEntity(Company.self, filter: filter, sort: nil).first else { print("could not get coredata company object - Sign Up Company Name View Controller"); return }
            coreDataCompanyObject.address = address
            
            self.navigationController?.pushViewController(signUpCompanyEmailViewController, animated: true)
        }
    }
    
    
    @IBAction func addressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.addressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
    
}

extension SignUpCompanyAddressViewController {
    
    // Google Places
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
    
    
    // Textfields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if !string.isEmpty {
            self.presentAutocomplete(textForSearchBar: string)
        }
        return true
    }
    
    // Maps
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
