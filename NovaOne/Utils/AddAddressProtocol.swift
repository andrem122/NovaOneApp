//
//  AddAddressProtocol.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 6/10/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import MapKit
import GooglePlaces

protocol AddAddress: GMSAutocompleteResultsViewControllerDelegate, MKMapViewDelegate, UITextFieldDelegate, CLLocationManagerDelegate {
    // A protocol for views that have a street address field populated with Google Places Autocomplete
    
    // MARK: Properties
    var addressTextField: NovaOneTextField! { get set }
    var continueButton: NovaOneButton! { get set }
    var mapView: MKMapView! { get set }
    var resultsViewController: GMSAutocompleteResultsViewController? { get set }
    var searchController: UISearchController? { get set }
    
    // MARK: Methods
    func setupMapView()
    func presentAutocomplete(textForSearchBar: String)
    func setupTextField()
    
    // For class extension
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace)
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error)
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
}
