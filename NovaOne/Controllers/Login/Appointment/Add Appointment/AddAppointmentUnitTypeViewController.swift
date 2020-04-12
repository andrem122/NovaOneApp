//
//  AddAppointmentUnitTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentUnitTypeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var unitTypePicker: UIPickerView!
    let unitTypes: [String] = ["3 Bedrooms", "2 Bedrooms", "1 Bedroom"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
        //self.setupBackButton()
    }
    
    func setupPicker() {
        self.unitTypePicker.delegate = self
        self.unitTypePicker.dataSource = self
    }
    
}

extension AddAppointmentUnitTypeViewController {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.unitTypes.count
    }
    
    // The value to show for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.unitTypes[row] // Get the string in the unitTypes array and display it for each row in the picker
    }
}
