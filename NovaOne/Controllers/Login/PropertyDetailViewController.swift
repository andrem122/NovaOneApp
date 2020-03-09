//
//  PropertyDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class PropertyDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Properties
    @IBOutlet weak var propertyDetailTableView: UITableView!
    var property: Property?
    var propertyDetailCells: [[String: Any]] = [[:]]
    
    // MARK: Methods
    func setup() {
        self.propertyDetailTableView.delegate = self
        self.propertyDetailTableView.dataSource = self
        
        // Set up cells
        guard let property = self.property else { return }
        guard
            let phoneNumber = property.phoneNumber,
            let email = property.email,
            let daysOfTheWeekEnabled = property.daysOfTheWeekEnabled
        else { return }
        let address = property.shortenedAddress
        
        let addressCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.locationBlue.rawValue) as Any, "cellTitle": "Address", "cellTitleValue": address, "canUpdateValue": true]
        let phoneNumberCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.callBlue.rawValue) as Any, "cellTitle": "Phone", "cellTitleValue": phoneNumber, "canUpdateValue": true]
        let emailCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.emailBlue.rawValue) as Any, "cellTitle": "Email", "cellTitleValue": email, "canUpdateValue": true]
        let daysOfTheWeekCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.calendarBlue.rawValue) as Any, "cellTitle": "Showing Days", "cellTitleValue": daysOfTheWeekEnabled, "canUpdateValue": true]
        
        self.propertyDetailCells = [addressCell, phoneNumberCell, emailCell, daysOfTheWeekCell]
        
    }
    
    // Gets a view controller vy a string identifier
    func getViewController(by identifier: String) -> UIViewController {
        guard let viewController = self.storyboard?.instantiateViewController(identifier: identifier) else { return UIViewController() }
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    

}

extension PropertyDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.propertyDetailCells.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.CellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let propertydetailCell = self.propertyDetailCells[indexPath.row]
        
        cell.setup(cellIcon: propertydetailCell["cellIcon"] as! UIImage, cellTitle: propertydetailCell["cellTitle"] as! String, cellTitleValue: propertydetailCell["cellTitleValue"] as! String, canUpdateValue: propertydetailCell["canUpdateValue"] as! Bool)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Get propertyDetail object based on which row the user taps on
        let cellTitle = self.propertyDetailCells[indexPath.row]["cellTitle"] as! String
        
        //Get update view controller based on which cell the user clicked on
        switch cellTitle {
            case "Address":
                if let updateAddressViewController = self.getViewController(by: Defaults.ViewControllerIdentifiers.updateAddress.rawValue) as? UpdateStreetAddressViewController {
                    self.present(updateAddressViewController, animated: true, completion: nil)
            }
            case "Phone":
                if let updatePhoneViewController = self.getViewController(by: Defaults.ViewControllerIdentifiers.updatePhone.rawValue) as? UpdatePhoneViewController {
                    self.present(updatePhoneViewController, animated: true, completion: nil)
                }
            default:
                print("Hello!")
        }
        
    }
    
}
