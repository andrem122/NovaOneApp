//
//  UpdateAppointmentUnitTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentUnitTypeViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var unitTypePicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let unitTypes = ["1 Bedroom", "2 Bedrooms", "3 Bedrooms"]
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.unitTypePicker.delegate = self
        self.unitTypePicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
}

extension UpdateAppointmentUnitTypeViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.unitTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.unitTypes[row]
    }
    
}
