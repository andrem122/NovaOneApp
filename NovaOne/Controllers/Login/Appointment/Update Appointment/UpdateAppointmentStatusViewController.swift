//
//  UpdateAppointmentStatusViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/11/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateAppointmentStatusViewController: UpdateBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var statusPicker: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let statusChoices = ["Confirmed", "Not Confirmed"]
    
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        self.statusPicker.delegate = self
        self.statusPicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
    }
    
}

extension UpdateAppointmentStatusViewController {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.statusChoices.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.statusChoices[row]
    }
}
