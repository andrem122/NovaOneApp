//
//  NovaOneDetailViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/6/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit

class AppointmentDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NovaOneObjectDetail {
    
    // MARK: Properties
    var objectDetailItems: [ObjectDetailItem] = []
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var objectDetailTableView: UITableView!
    @IBOutlet weak var topView: NovaOneView!
    var alertService: AlertService = AlertService()
    var previousViewController: UIViewController?
    var coreDataObjectId: Int32?
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var loadingViewSpinner: UIActivityIndicatorView!
    weak var cachedAppointment: Appointment?
    var appointment: Appointment? {
        get {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            
            guard nil == self.cachedAppointment else {
                return self.cachedAppointment!
            }
            
            // If cachedCustomer is nil, then get the customer object throught managed context object
            guard let coreDataObjectId = self.coreDataObjectId else { print("could not get core data object id - AppointmentDetailViewController"); return nil }
            let filter = NSPredicate(format: "id == %@", String(coreDataObjectId))
            guard let appointment = PersistenceService.fetchEntity(Appointment.self, filter: filter, sort: nil).first else {
                print("Appointment object does not exist - AppointmentDetailViewController")
                return nil
            }
            
            self.cachedAppointment = appointment
            return self.cachedAppointment!
            
        }
        
        set {
            self.cachedAppointment = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupObjectDetailCellsAndTitle()
        self.setupTableView()
        self.setupTopView()
        self.setupNavigationBar()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            [weak self] in
            self?.hideLoadingView()
        }
    }
    
    func hideLoadingView() {
        // Hides loading view an activity indicator
        self.loadingView.isHidden = true
        self.loadingViewSpinner.stopAnimating()
    }
    
    func setupNavigationBar() {
        // Set up the navigation bar
        UIHelper.setupNavigationBarStyle(for: self.navigationController)
    }
    
    func setupTopView() {
        // Set up top view style
        self.topView.clipsToBounds = true
        self.topView.layer.cornerRadius = 50
        self.topView.layer.maskedCorners = [.layerMinXMaxYCorner]
    }
    
    func setupTableView() {
        // Set up the table view
        self.objectDetailTableView.delegate = self
        self.objectDetailTableView.dataSource = self
        self.objectDetailTableView.rowHeight = 44;
    }
    
    func setupObjectDetailCellsAndTitle() {
        // Set cells up for the table view
        
        // Get attributes from core data object
        guard
            let appointment = self.appointment,
            let name = appointment.name,
            let time = appointment.time,
            let phoneNumber = appointment.phoneNumber
        else { return }
        
        let appointmentTime: String = DateHelper.createString(from: time, format: "MMM d, yyyy | h:mm a")
        let confirmedString = appointment.confirmed ? "Yes" : "No"
        
        // Create items for cells
        let nameItem = ObjectDetailItem(titleValue: name, titleItem: .name)
        let phoneNumberItem = ObjectDetailItem(titleValue: phoneNumber, titleItem: .phoneNumber)
        let appointmentTimeItem = ObjectDetailItem(titleValue: appointmentTime, titleItem: .appointmentTime)
        let appointmentConfirmedItem = ObjectDetailItem(titleValue: confirmedString, titleItem: .confirmed)
        
        // Set title label of detail view controller
        self.titleLabel.text = appointment.name
        
        // Add to table cells array
        self.objectDetailItems = [
            nameItem,
            phoneNumberItem,
            appointmentTimeItem,
            appointmentConfirmedItem]
        
        // Additional cells for different customer types
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerType = customer.customerType
        else { return }
        
        if customerType == Defaults.CustomerTypes.propertyManager.rawValue {
            
            guard let unitType = appointment.unitType else { return }
            let unitTypeItem = ObjectDetailItem(titleValue: unitType, titleItem: .unitType)
            self.objectDetailItems.append(unitTypeItem)
            
        } else if customerType == Defaults.CustomerTypes.medicalWorker.rawValue {
            
            guard
                let email = appointment.email,
                let dateOfBirthDate = appointment.dateOfBirth,
                let testType = appointment.testType,
                let gender = appointment.gender,
                let shortenedAddress = appointment.address?.components(separatedBy: ",").first,
                let city = appointment.city,
                let zip = appointment.zip
            else { return }
            let dateOfBirth = DateHelper.createString(from: dateOfBirthDate, format: "MM/dd/yyyy")
            
            let emailItem = ObjectDetailItem(titleValue: email, titleItem: .email)
            let dateOfBirthItem = ObjectDetailItem(titleValue: dateOfBirth, titleItem: .dateOfBirth)
            let testTypeItem = ObjectDetailItem(titleValue: testType, titleItem: .testType)
            let genderItem = ObjectDetailItem(titleValue: gender, titleItem: .gender)
            let addressItem = ObjectDetailItem(titleValue: shortenedAddress, titleItem: .address)
            let cityItem = ObjectDetailItem(titleValue: city, titleItem: .city)
            let zipItem = ObjectDetailItem(titleValue: zip, titleItem: .zip)
            
            let items = [emailItem, dateOfBirthItem, testTypeItem, genderItem, addressItem, cityItem, zipItem]
            self.objectDetailItems.append(contentsOf: items)
            
        }
    }
    
    // MARK: Actions
    @IBAction func deleteButtonTapped(_ sender: Any) {
        // Set text for pop up view controller
        let title = "Delete?"
        let body = "Are you sure you want to delete the appointment?"
        let buttonTitle = "Delete"
        
        let popUpViewController = alertService.popUp(title: title, body: body, buttonTitle: buttonTitle, actionHandler: {
            [weak self] in
            
            guard
                let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
                let email = customer.email,
                let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue),
                let objectId = self?.appointment?.id,
                let appointment = self?.appointment
            else { return }
            
            // Remove the detail view controller from view
            guard let objectsTableViewController = self?.previousViewController as? NovaOneTableView else { print("could not get objectsTableViewController - lead detail view"); return }
            guard let containerViewControllerAsUIViewController = objectsTableViewController.parentViewContainerController else { print("could not get containerViewController - lead detail view"); return }
            guard let containerViewControllerView = objectsTableViewController.parentViewContainerController?.view else { print("could not get containerViewControllerView - lead detail view"); return }
            
            let spinnerView = containerViewControllerAsUIViewController.showSpinner(for: containerViewControllerView, textForLabel: "Deleting")
            self?.performSegue(withIdentifier: Defaults.SegueIdentifiers.unwindToAppointments.rawValue, sender: self)
            
            // Delete from CoreData
            let context = PersistenceService.privateChildManagedObjectContext()
            context.delete(appointment)
            PersistenceService.saveContext(context: context)
            
            // Delete from NovaOne database
            let parameters: [String: Any] = ["email": email,
                                             "password": password,
                                             "columnName": "id",
                                             "objectId": objectId,]
            
            let httpRequest = HTTPRequests()
            let endpoint = customer.customerType == "MW" ? "/deleteAppointmentMedical.php" : "/deleteAppointmentRealEstate.php"
            httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint, dataModel: SuccessResponse.self, parameters: parameters) {(result) in
            
                switch result {
                    case .success(_):
                        // If no more objects exist, go to empty view controller else go to table view controller and reload data
                        let count = PersistenceService.fetchCount(for: Defaults.CoreDataEntities.appointment.rawValue)
                        if count > 0 {
                            
                            // Return to the objects view and refresh objects
                            objectsTableViewController.refreshDataOnPullDown()
                            
                        } else {
                            
                            // No more objects to show so go to the empty view controller screen
                            guard let containerViewController = containerViewControllerAsUIViewController as? NovaOneObjectContainer else { return }
                            
                            UIHelper.showEmptyStateContainerViewController(for: containerViewController as? UIViewController, containerView: containerViewController.containerView ?? UIView(), title: "No Appointments", addObjectButtonTitle: "Add Appointment") {
                                (emptyViewController) in
                                
                                // Tell the empty state view controller what its parent view controller is
                                emptyViewController.parentViewContainerController = containerViewController as? UIViewController
                                
                                // Pass the addObjectHandler function and button title to the empty view controller
                                emptyViewController.addObjectButtonHandler = {
                                    // Go to the add object screen
                                    let addAppointmentStoryboard = UIStoryboard(name: Defaults.StoryBoards.addAppointment.rawValue, bundle: .main)
                                    guard
                                        let addAppointmentNavigationController = addAppointmentStoryboard.instantiateViewController(identifier: Defaults.NavigationControllerIdentifiers.addAppointment.rawValue) as? UINavigationController,
                                        let addAppointmentCompanyViewController = addAppointmentNavigationController.viewControllers.first as? AddAppointmentCompanyViewController
                                    else { return }
                                    
                                    addAppointmentCompanyViewController.embeddedViewController = emptyViewController
                                    
                                    (containerViewController as? UIViewController)?.present(addAppointmentNavigationController, animated: true, completion: nil)
                                }
                                
                            }
                            
                        }
                    case .failure(let error):
                        guard let containerViewController = containerViewControllerAsUIViewController as? NovaOneObjectContainer else { return }
                        let popUpOkViewController = containerViewController.alertService.popUpOk(title: "Error", body: error.localizedDescription)
                        containerViewControllerAsUIViewController.present(popUpOkViewController, animated: true, completion: nil)
                }
                
                containerViewControllerAsUIViewController.removeSpinner(spinnerView: spinnerView)
            }
        }, cancelHandler: {
            print("Action canceled")
        })
        
        self.present(popUpViewController, animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
}

extension AppointmentDetailViewController {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.objectDetailItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Defaults.TableViewCellIdentifiers.objectDetail.rawValue) as! ObjectDetailTableViewCell
        
        let objectDetailItem = self.objectDetailItems[indexPath.row]
        cell.objectDetailItem = objectDetailItem
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true) // Deselect the row after it is tapped on
        let updateAppointmentStoryboard = UIStoryboard(name: Defaults.StoryBoards.updateAppointment.rawValue, bundle: .main)
            
        // Get company title based on which row the user taps on
        let titleItem = self.objectDetailItems[indexPath.row].titleItem
        
            // Get update view controller based on which cell the user clicked on
            switch titleItem {
                case .name:
                    if let updateAppointmentNameViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentName.rawValue) as? UpdateAppointmentNameViewController {
                        
                        updateAppointmentNameViewController.updateCoreDataObjectId = self.coreDataObjectId
                        updateAppointmentNameViewController.previousViewController = self
                        updateAppointmentNameViewController.modalPresentationStyle = .fullScreen
                        
                        self.present(updateAppointmentNameViewController, animated: true, completion: nil)
                        
                    }
                case .email:
                        if let updateAppointmentEmailViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentEmail.rawValue) as? UpdateAppointmentEmailViewController {
                            
                            updateAppointmentEmailViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentEmailViewController.previousViewController = self
                            updateAppointmentEmailViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentEmailViewController, animated: true, completion: nil)
                            
                        }
                    
                case .phoneNumber:
                        if let updateAppointmentPhoneViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentPhone.rawValue) as? UpdateAppointmentPhoneViewController {
                            
                            updateAppointmentPhoneViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentPhoneViewController.previousViewController = self
                            updateAppointmentPhoneViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentPhoneViewController, animated: true, completion: nil)
                            
                        }
                    
                case .appointmentTime:
                        if let updateAppointmentTimeViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentTime.rawValue) as? UpdateAppointmentTimeViewController {
                            
                            updateAppointmentTimeViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentTimeViewController.previousViewController = self
                            updateAppointmentTimeViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentTimeViewController, animated: true, completion: nil)
                            
                        }
                    
                case .confirmed:
                        if let updateAppointmentStatusViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentStatus.rawValue) as? UpdateAppointmentStatusViewController {
                            
                            updateAppointmentStatusViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentStatusViewController.previousViewController = self
                            updateAppointmentStatusViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentStatusViewController, animated: true, completion: nil)
                            
                        }
                    
                case .dateOfBirth:
                        if let updateAppointmentDateOfBirthViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentDateOfBirth.rawValue) as? UpdateAppointmentDateOfBirthViewController {
                            
                            updateAppointmentDateOfBirthViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentDateOfBirthViewController.previousViewController = self
                            updateAppointmentDateOfBirthViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentDateOfBirthViewController, animated: true, completion: nil)
                            
                        }
                    
                case .unitType:
                        if let updateAppointmentUnitTypeViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentUnitType.rawValue) as? UpdateAppointmentUnitTypeViewController {
                            
                            updateAppointmentUnitTypeViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentUnitTypeViewController.previousViewController = self
                            updateAppointmentUnitTypeViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentUnitTypeViewController, animated: true, completion: nil)
                            
                        }
                    
                case .testType:
                        if let updateAppointmentTestTypeViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentTestType.rawValue) as? UpdateAppointmentTestTypeViewController {
                            
                            updateAppointmentTestTypeViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentTestTypeViewController.previousViewController = self
                            updateAppointmentTestTypeViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentTestTypeViewController, animated: true, completion: nil)
                            
                        }
                    
                case .gender:
                        if let updateAppointmentGenderViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentGender.rawValue) as? UpdateAppointmentGenderViewController {
                            
                            updateAppointmentGenderViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentGenderViewController.previousViewController = self
                            updateAppointmentGenderViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentGenderViewController, animated: true, completion: nil)
                            
                        }
                    
                case .address:
                        if let updateAppointmentAddressViewController = updateAppointmentStoryboard.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.updateAppointmentAddress.rawValue) as? UpdateAppointmentAddressViewController {
                            
                            updateAppointmentAddressViewController.updateCoreDataObjectId = self.coreDataObjectId
                            updateAppointmentAddressViewController.previousViewController = self
                            updateAppointmentAddressViewController.modalPresentationStyle = .fullScreen
                            
                            self.present(updateAppointmentAddressViewController, animated: true, completion: nil)
                            
                        }
            case .city:
                guard
                    let city = self.appointment?.city
                else { return }
                UIPasteboard.general.string = city
                
                // Show popup confirming that text has been copied
                let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "City has been copied to clipboard successfully. Note: to update the city, update the address for this appointment.")
                self.present(popUpOkViewController, animated: true, completion: nil)
            case .zip:
                guard
                    let zip = self.appointment?.zip
                else { return }
                UIPasteboard.general.string = zip
                
                // Show popup confirming that text has been copied
                let popUpOkViewController = self.alertService.popUpOk(title: "Text Copied!", body: "Zip has been copied to clipboard successfully. Note: to update the zip, update the address for this appointment.")
                self.present(popUpOkViewController, animated: true, completion: nil)
                    
                    default:
                        print("No cases matched")
            }

    }
    
}
