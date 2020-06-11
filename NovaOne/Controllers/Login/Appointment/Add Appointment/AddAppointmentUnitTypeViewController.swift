//
//  AddAppointmentUnitTypeViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentUnitTypeViewController: AddAppointmentBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var unitTypePicker: UIPickerView!
    let unitTypes: [String] = ["3 Bedrooms", "2 Bedrooms", "1 Bedroom"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
        self.setUnitTypeDefaultValue()
    }
    
    func setUnitTypeDefaultValue() {
        // Sets the default value for unit type if the user does not pick from the picker
        self.appointment?.unitType = self.unitTypes.first
    }
    
    func setupPicker() {
        self.unitTypePicker.delegate = self
        self.unitTypePicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func addAppointmentButtonTapped(_ sender: Any) {
        self.showSpinner(for: self.view, textForLabel: "Adding Appointment...")
        
        guard
            let companyId = self.appointment?.companyId,
            let name = self.appointment?.name,
            let phoneNumber = self.appointment?.phoneNumber,
            let unitType = self.appointment?.unitType,
            let time = self.appointment?.time
        else { return }
        let url = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
        
        // Make HTTP request to create an appointment
        let httpRequest = HTTPRequests()
        let parameters = ["name": name, "unit_type": unitType, "phone_number": phoneNumber, "time": time]
        httpRequest.request(url: url, dataModel: SuccessResponse.self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
            case .success(let success):
                // Redirect to success screen
                
                self?.removeSpinner()
                
                guard let successViewController = self?.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.success.rawValue) as? SuccessViewController else { return }
                successViewController.subtitleText = success.successReason
                successViewController.titleLabelText = "Appointment Created!"
                successViewController.doneHandler = {
                    [weak self] in
                    // Return to the appointments view and refresh appointments
                    self?.presentingViewController?.dismiss(animated: true, completion: nil)
                    self?.appointmentsTableViewController?.refreshDataOnPullDown()
                }
                self?.present(successViewController, animated: true, completion: nil)
            case .failure(let error):
                self?.removeSpinner()
                guard let popUpOk = self?.alertService.popUpOk(title: "Error", body: error.localizedDescription) else { return }
                self?.present(popUpOk, animated: true, completion: nil)
            }
            
        }
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.appointment?.unitType = self.unitTypes[row]
    }
}
