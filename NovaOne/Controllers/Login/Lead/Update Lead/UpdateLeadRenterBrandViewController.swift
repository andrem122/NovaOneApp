//
//  UpdateLeadRenterBrandViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 7/8/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class UpdateLeadRenterBrandViewController: UpdateBaseViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var updateButton: NovaOneButton!
    let renterBrands: [String] = [
    "Zillow",
    "Trulia",
    "Realtor",
    "Apartments.com",
    "Hotpads",
    "Craigslist",
    "Move",
    "Other"]
    lazy var selectedChoice: String = {
        guard let renterBrand = self.renterBrands.first else { return "" }
        return renterBrand
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupPicker()
    }
    
    func setupPicker() {
        // Setup the picker view
        self.pickerView.delegate = self
        self.pickerView.dataSource = self
    }
    

   // MARK: Actions
    @IBAction func updateButtonTapped(_ sender: Any) {
        guard
            let objectId = self.updateCoreDataObjectId,
            let detailViewController = self.previousViewController as? LeadDetailViewController
        else { return }
        
        let updateClosure = {
            (lead: Lead) in
            lead.renterBrand = self.selectedChoice
        }
        
        let successDoneHandler = {
            let predicate = NSPredicate(format: "id == %@", String(objectId))
            guard let updatedLead = PersistenceService.fetchEntity(Lead.self, filter: predicate, sort: nil).first else { return }
            
            detailViewController.coreDataObjectId = updatedLead.id
            detailViewController.setupObjectDetailCellsAndTitle()
            detailViewController.objectDetailTableView.reloadData()
        }
        
        self.updateObject(for: Defaults.DataBaseTableNames.leads.rawValue, at: ["renter_brand": self.selectedChoice], endpoint: "/updateObject.php", objectId: Int(objectId), objectType: Lead.self, updateClosure: updateClosure, filterFormat: "id == %@", successSubtitle: "Renter brand has been successfully updated.", successDoneHandler: successDoneHandler, completion: nil)
    }
    
}

extension UpdateLeadRenterBrandViewController {
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
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selectedChoice = self.renterBrands[row]
    }
}
