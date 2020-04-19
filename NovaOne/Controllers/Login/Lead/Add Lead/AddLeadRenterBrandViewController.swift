//
//  AddLeadRenterBrandViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddLeadRenterBrandViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var picker: UIPickerView!
    let renterBrands: [String] = [
        "Zillow",
        "Trulia",
        "Realtor",
        "Apartments.com",
        "Hotpads",
        "Craigslist",
        "Move",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        // Setup the picker view
        self.picker.delegate = self
        self.picker.dataSource = self
    }

}

extension AddLeadRenterBrandViewController {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.renterBrands.count
    }
    
    // The value to show for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.renterBrands[row] // Get the string in the genders array and display it for each row in the picker
    }
    
}
