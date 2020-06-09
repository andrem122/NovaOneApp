//
//  AddAppointmentCompanyViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/12/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData

class AddAppointmentCompanyViewController: AddAppointmentBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
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
    
    func setupTableView() {
        self.tableView.rowHeight = 44
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
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        // Check if item was selected in table
        if EnableOptionHelper.optionIsSelected(options: self.options) == true {
            guard let addAppointmentNameViewController = self.storyboard?.instantiateViewController(identifier: Defaults.ViewControllerIdentifiers.addAppointmentName.rawValue) as? AddAppointmentNameViewController else { return }
            
            // Get selected options and pass objects
            let selectedOption = self.options.filter({ $0.selected == true }).first
            guard let companyId = selectedOption?.id else { return }
            
            // Create appointment model object and pass company id to it
            self.appointment = AppointmentModel(id: nil, name: "", phoneNumber: "", time: "", created: nil, timeZone: "US/Eastern", confirmed: false, companyId: companyId, unitType: "", email: "", dateOfBirth: "", testType: "", gender: "", address: "")
            addAppointmentNameViewController.appointment = self.appointment
            addAppointmentNameViewController.appointmentsTableViewController = self.appointmentsTableViewController
            
            self.navigationController?.pushViewController(addAppointmentNameViewController, animated: true)
        } else {
            let popUpOkViewController = self.alertService.popUpOk(title: "Select A Company", body: "Please select a company.")
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
}

extension AddAppointmentCompanyViewController {
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
