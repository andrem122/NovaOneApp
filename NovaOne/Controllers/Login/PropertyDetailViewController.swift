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
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var topView: NovaOneView!
    var property: Property?
    var propertyDetailCells: [[String: Any]] = [[:]]
    
    
    // MARK: Methods
    func setup() {
        self.propertyDetailTableView.delegate = self
        self.propertyDetailTableView.dataSource = self
        
        // Set up cells
        guard let property = self.property else { return }
        guard
            let name = property.name,
            let phoneNumber = property.phoneNumber,
            let email = property.email
        else { return }
        let address = property.shortenedAddress
        
        let nameCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.locationBlue.rawValue) as Any, "cellTitle": "Name", "cellTitleValue": name, "canUpdateValue": true]
        let addressCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.locationBlue.rawValue) as Any, "cellTitle": "Address", "cellTitleValue": address, "canUpdateValue": true]
        let phoneNumberCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.callBlue.rawValue) as Any, "cellTitle": "Phone", "cellTitleValue": phoneNumber, "canUpdateValue": true]
        let emailCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.emailBlue.rawValue) as Any, "cellTitle": "Email", "cellTitleValue": email, "canUpdateValue": true]
        let daysOfTheWeekCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.calendarBlue.rawValue) as Any, "cellTitle": "Showing Days", "cellTitleValue": "", "canUpdateValue": true]
        let hoursOfTheDayCell: [String: Any] = ["cellIcon": UIImage(named: Defaults.Images.calendarBlue.rawValue) as Any, "cellTitle": "Showing Hours", "cellTitleValue": "", "canUpdateValue": true]
        
        self.propertyDetailCells = [nameCell, addressCell, phoneNumberCell, emailCell, daysOfTheWeekCell, hoursOfTheDayCell]
        
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
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
                if let updatePropertyAddressViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyAddress.rawValue) as? UpdatePropertyAddressViewController {
                    self.present(updatePropertyAddressViewController, animated: true, completion: nil)
            }
            case "Phone":
                if let updatePropertyPhoneViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyPhone.rawValue) as? UpdatePropertyPhoneViewController {
                    self.present(updatePropertyPhoneViewController, animated: true, completion: nil)
                }
        case "Name":
            if let updatePropertyNameViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyName.rawValue) as? UpdatePropertyNameViewController {
                self.present(updatePropertyNameViewController, animated: true, completion: nil)
            }
        case "Email":
            if let updatePropertyEmailViewController = UIHelper.getViewController(currentViewController: self, by: Defaults.ViewControllerIdentifiers.updatePropertyEmail.rawValue) as? UpdatePropertyEmailViewController {
                self.present(updatePropertyEmailViewController, animated: true, completion: nil)
            }
        case "Showing Days":
            print("Hello")
        case "Showing Hours":
            print("Hello1")
            default:
                print("Hello!")
        }
        
    }
    
}
