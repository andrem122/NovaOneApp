//
//  AddAppointmentTestTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentTestTypeViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
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
                               "MetLac 12 Panel",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
        //self.setupBackButton()
    }
    
    func setupPicker() {
        self.testTypePicker.delegate = self
        self.testTypePicker.dataSource = self
    }

}

extension AddAppointmentTestTypeViewController {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.testTypes.count
    }
    
    // The value to show for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.testTypes[row] // Get the string in the testTypes array and display it for each row in the picker
    }
}
