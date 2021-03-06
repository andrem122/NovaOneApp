//
//  AddLeadCompanyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/19/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class AddLeadCompanyViewController: AddLeadBaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
        var options: [EnableOption] = []
    var companies: [Any]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getCompanies()
        self.setupTableView()
        self.setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Rotate the orientation of the screen to potrait and lock it
        AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    }
    
    func setupTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    func setupNavigationBar() {
        // Set navigation bar style
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    func getCompanies() {
        // Get customer companies from CoreData
        // Set up attributes for options array
        let companies = PersistenceService.fetchEntity(Company.self, filter: nil, sort: nil)
        for company in companies {
            
            guard let companyName = company.name else { return }
            let option = EnableOption(option: companyName, selected: false, id: Int(company.id))
            self.options.append(option)
            
        }
    }
    
    // MARK: Actions
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
        
        // Allow all orientaions after cancel button is tapped
        AppUtility.lockOrientation(.all)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Check if item was selected in table
        if EnableOptionHelper.optionIsSelected(options: self.options) == true {
            guard let addLeadNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addLeadName.rawValue) as? AddLeadNameViewController else { return }
            
            // Get selected options and pass objects
            let selectedOption = self.options.filter({ $0.selected == true }).first
            guard let companyId = selectedOption?.id else { return }
            
            // Create appointment model object and pass company id to it
            self.lead = LeadModel(id: nil, name: "", phoneNumber: "", email: "", dateOfInquiry: "", renterBrand: "", companyId: companyId, sentTextDate: nil, sentEmailDate: nil, filledOutForm: false, madeAppointment: false, companyName: "")
            addLeadNameViewController.lead = self.lead
            addLeadNameViewController.embeddedViewController = self.embeddedViewController
            
            self.navigationController?.pushViewController(addLeadNameViewController, animated: true)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select Company", body: "Please select a company.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension AddLeadCompanyViewController {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        
        // Deselect all other selections. Only one company may be selected
        for (count, _) in self.options.enumerated() {
            self.options[count].selected = false
        }
        
        let cell = tableView.cellForRow(at: indexPath) as! EnableOptionTableViewCell
        let selected = cell.toggleCheckMark(cell: cell)
        self.options[indexPath.row].selected = selected
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.enableOption.rawValue) as! EnableOptionTableViewCell
        
        let enableOption = self.options[indexPath.row] // Get the EnableOption object
        cell.prepareCellForReuse(cell: cell, enableOption: enableOption)
        return cell
        
    }
    
}
