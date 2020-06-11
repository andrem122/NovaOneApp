//
//  AddAppointmentGenderViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AddAppointmentGenderViewController: AddAppointmentBaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var genderPicker: UIPickerView!
    let genders: [String] = ["Male", "Female"]
    lazy var genderType: String = {
        guard
            let firstGenderType = self.genders.first,
            let firstCharacter = firstGenderType.first
        else { return "" }
        return String(firstCharacter)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
        print(self.appointment as Any)
    }
    
    func setupPicker() {
        self.genderPicker.delegate = self
        self.genderPicker.dataSource = self
    }
    
    // MARK: Actions
    @IBAction func addAppointmentButtonTapped(_ sender: Any) {
        self.showSpinner(for: self.view, textForLabel: "Adding Appointment...")
        
        guard
            let companyId = self.appointment?.companyId,
            let name = self.appointment?.name,
            let phoneNumber = self.appointment?.phoneNumber,
            let testType = self.appointment?.testType,
            let dateOfBirth = self.appointment?.dateOfBirth,
            let address = self.appointment?.address,
            let email = self.appointment?.email,
            let time = self.appointment?.time
        else { return }
        let url = Defaults.Urls.novaOneWebsite.rawValue + "/appointments/new?c=\(companyId)"
        
        // Make HTTP request to create an appointment
        let httpRequest = HTTPRequests()
        let parameters = [
            "name": name,
            "phone_number": phoneNumber,
            "test_type": testType,
            "gender": self.genderType,
            "date_of_birth": dateOfBirth,
            "address": address,
            "email": email,
            "time": time]
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

extension AddAppointmentGenderViewController {
    
    // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // Number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.genders.count
    }
    
    // The value to show for each row in the picker
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.genders[row] // Get the string in the genders array and display it for each row in the picker
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.genderType = self.genders[row] == "Male" ? "M" : "F"
    }
    
}
