//
//  SignUpAddressViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/2/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import GooglePlaces

class SignUpCompanyAddressViewController: BaseSignUpViewController, GMSAutocompleteViewControllerDelegate {
    
    // MARK: Properties
    @IBOutlet weak var addressTextField: NovaOneTextField!
    @IBOutlet weak var continueButton: NovaOneButton!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    let autocompleteController = GMSAutocompleteViewController()
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make text field become first responder
        self.addressTextField.becomeFirstResponder()
    }
    
    func setup() {
        self.autocompleteController.delegate = self
        UIHelper.disable(button: self.continueButton, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil)
    }
    
    // MARK: Actions
    @IBAction func addressTextFieldChanged(_ sender: Any) {
        UIHelper.toggle(button: self.continueButton, textField: self.addressTextField, enabledColor: Defaults.novaOneColor, disabledColor: Defaults.novaOneColorDisabledColor, borderedButton: nil, closure: nil)
        
        guard let address = self.addressTextField.text else { return }
        self.present(autocompleteController, animated: true) {
            [weak self] in
            
            guard let views = self?.autocompleteController.view.subviews else { return }
            
            guard let subview = views.first else { return }
            let subviewsOfSubview = subview.subviews
            let subOfNavTransitionView = subviewsOfSubview[0].subviews
            let subOfContentView = subOfNavTransitionView[0].subviews
            
            guard let searchBar = subOfContentView[0] as? UISearchBar else { return }
            searchBar.text = address
            searchBar.delegate?.searchBar?(searchBar, textDidChange: address)
            
        }
        
    }
    
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        guard let signUpCompanyCityViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.signUpCompanyCity.rawValue) as? SignUpCompanyCityViewController else { return }
        
        
        
        self.present(signUpCompanyCityViewController, animated: true, completion: nil)
    }
    
}

extension SignUpCompanyAddressViewController {
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Place was selected from autocomplete
        
        self.dismiss(animated: true) {
            guard let selectedAddress = place.formattedAddress else { return }
            self.addressTextField.text = selectedAddress
            self.company?.address = selectedAddress
            
            guard let addressComponents = place.addressComponents else { return }
            
            for component in addressComponents {
                
                let componentType = component.types[0]
                if componentType == "locality" { // City
                    self.company?.city = component.name
                } else if componentType == "administrative_area_level_1" { // State
                    guard let state = component.shortName else { return }
                    self.company?.state = state
                } else if componentType == "postal_code" { // Zip code
                    self.company?.zip = component.name
                }
                
            }
        }
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Autocomplete Error: ", error.localizedDescription)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
