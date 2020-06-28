//
//  UpdateAppointmentTestTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentTestTypeViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var testTypePicker: UIPickerView!
    let testTypes: [String] = ["Comprehensive Metabolic Panel",
                               "Basic Metabolic Panel",
                               "Lipid Panel",
                               "Lipid Panel Plus",
                               "Liver Panel Plus",
                               "General Chemistry 6",
                               "General Chemistry 13",
                               "Electrolyte Panel",
                               "Kidney Check",
                               "Renal Function Panel",
                               "MetLyte 8 Panel",
                               "Hepatic Function Panel",
                               "Basic Metabolic Panel Plus",
                               "MetLyte Plus CRP",
                               "Biochemistry Panel Plus",
                               "MetLac 12 Panel"]
    
    @IBOutlet weak var updateButton: NovaOneButton!
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        // Set up the picker view
        self.testTypePicker.delegate = self
        self.testTypePicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
    
}

extension UpdateAppointmentTestTypeViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.testTypes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.testTypes[row]
    }
    
}

