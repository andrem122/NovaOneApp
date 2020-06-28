//
//  UpdateAppointmentGenderViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentGenderViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let genders = ["Male", "Female"]
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
    
}

extension UpdateAppointmentGenderViewController {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genders[row]
    }
    
}
