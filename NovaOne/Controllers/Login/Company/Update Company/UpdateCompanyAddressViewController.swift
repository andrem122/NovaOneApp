//
//  UpdateAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 2/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces

class UpdateCompanyAddressViewController: UpdateBaseViewController, AddAddress {
    
    // MARK: Properties
    @IBOutlet weak var updateButton: NovaOneButton!
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var mapView: MKMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var address: String?
    var city: String?
    var state: String?
    var zip: String?
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupUpdateButton(button: self.updateButton)
        self.setupTextField(textField: self.addressTextField)
        self.setupMapView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        self.resultsViewController?.delegate = self
        
        // Style for dark and light mode
        guard
            let textColor = UIColor(named: Defaults.Colors.text.rawValue),
            let textFieldColor = UIColor(named: Defaults.Colors.textField.rawValue),
            let tableCellBackgroundColor = UIColor(named: Defaults.Colors.viewForeground.rawValue)
        else { return }
        
        self.resultsViewController?.primaryTextColor = textColor
        self.resultsViewController?.secondaryTextColor = textFieldColor
        self.resultsViewController?.tableCellSeparatorColor = textFieldColor
        self.resultsViewController?.tableCellBackgroundColor = tableCellBackgroundColor
        
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
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        // Check if an address has been selected before updating
        guard let address = self.address else { return }
        if address.isEmpty {
            
            let popUpOkViewController = self.alertService.popUpOk(title: "No Address", body: "Please type in and select an address.")
            self.present(popUpOkViewController, animated: true, completion: nil)
            
        } else {
            guard
                let city = self.city,
                let state = self.state,
                let zip = self.zip,
                let objectId = self.updateCoreDataObjectId,
                let detailViewController = self.previousViewController as? CompanyDetailViewController
            else { print("error getting detail view controller"); return }
            
            let updateClosure = {
                (company: Company) in
                company.address = address
                let shortenedAddress = address.components(separatedBy: ",")[0]
                company.shortenedAddress = shortenedAddress
                company.city = city
                company.state = state
                company.zip = zip
            }
            
            let successDoneHandler = {
                let predicate = NSPredicate(format: "id == %@", String(objectId))
                guard let updatedCompany = PersistenceService.fetchEntity(Company.self, filter: predicate, sort: nil).first else { return }
                detailViewController.company = updatedCompany
                detailViewController.coreDataObjectId = objectId
                detailViewController.setupObjectDetailCellsAndTitle()
                detailViewController.objectDetailTableView.reloadData()
            }
            
            self.updateObject(for: Defaults.DataBaseTableNames.company.rawValue, at: ["address": address, "city": city, "state": state, "zip": zip], endpoint: "/updateCompanyAddress.php", objectId: Int(objectId), objectType: Company.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Company address has been successfully updated.", currentAuthenticationEmail: nil, successDoneHandler: successDoneHandler, completion: nil)
            
            
        }
    }
    
    @IBAction func addressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.updateButton, textField: self.addressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: false, closure: nil)
    }
}

extension UpdateCompanyAddressViewController {
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
            self.dismiss(animated: true) {
                [weak self] in
                
                guard
                    let addressComponents = place.addressComponents,
                    let address = place.formattedAddress,
                    let updateButton = self?.updateButton
                else { return }
                
                // Enable button
                UIHelper.enable(button: updateButton, enabledColor: Defaults.novaOneColor, borderedButton: false)
                
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
                self?.address = address
                for component in addressComponents {
                    
                    let componentType = component.types[0]
                    if componentType == Defaults.GooglePlaceAddressComponents.city.rawValue { // City
                        self?.city = component.name
                    } else if componentType == Defaults.GooglePlaceAddressComponents.state.rawValue { // State
                        guard let state = component.shortName else { return }
                        self?.state = state
                    } else if componentType == Defaults.GooglePlaceAddressComponents.zip.rawValue { // Zip code
                        self?.zip = component.name
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
