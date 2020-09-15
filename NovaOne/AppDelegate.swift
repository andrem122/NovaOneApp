//
//  AppDelegate.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UserNotifications
import UIKit
import CoreData
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    /// Set orientations you want to be allowed in this property by default
    var orientationLock = UIInterfaceOrientationMask.all
    var window: UIWindow?

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
            return self.orientationLock
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSPlacesClient.provideAPIKey(Defaults.googlePlacesApiKey)
        
        UNUserNotificationCenter.current().delegate = self // Set the delegate for User Notification Center
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        PersistenceService.saveContext(context: nil)
    }
    
}

extension AppDelegate {
    // MARK: Push Notifications
    func registerForPushNotifications() {
        // Ask the user to enable push notifications
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] (granted, error) in
                print("Permission granted: \(granted)")
                
                guard granted else { return } // If granted is true, proceed with the below code else do not
                self?.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            
            guard settings.authorizationStatus == .authorized else { return } // User has authorized permissions for push notifications so proceed with below code
            
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func pushNotificationDataRefresh<T: Decodable>(endpoint: String, lastObjectId: Int32, objectType: T.Type, success: @escaping (T) -> Void) {
        // Refresh data when a push notification comes
        print("REFRESHING DATA FROM PUSH NOTIFICATION")
        
        // Get data through HTTP request
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else {
            print("unable to get data for data refresh - AppDelegate")
            return
        }
        let customerUserId = customer.id

        let parameters: [String: Any] = ["customerUserId": customerUserId as Any,
                                         "email": email as Any,
                                         "password": password as Any,
                                         "lastObjectId": lastObjectId as Any]
        
        httpRequest.request(url: Defaults.Urls.api.rawValue + endpoint, dataModel: objectType,
        parameters: parameters) { (result) in
            switch result {
                case .success(let objects):
                    success(objects)
                case .failure(let error):
                    print("Unable to update objects from push notification: \(error.localizedDescription)")
            }
        }
    }
    
    func sendDeviceTokenToServer(deviceToken: String) {
        // Sends the device token for push notifications to the NovaOne server
        // Make http request to NovaOne server with token
        let httpRequest = HTTPRequests()
        
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let customerEmail = customer.email,
            let customerPassword = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = String(customer.id)
        let columns = ["deviceToken": deviceToken, "type": "iOS", "customerUserId": customerUserId]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: columns) else { print("Unable to encode columns to JSON data object"); return }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else { print("unable to get string from json data"); return }
        
        let parameters: [String: Any] = ["email": customerEmail, "password": customerPassword, "columns": jsonString as Any]
        httpRequest.request(url: Defaults.Urls.api.rawValue + "/addDeviceToken.php", dataModel: SuccessResponse.self, parameters: parameters) { (result) in
            switch result {
                case .success(let successResponse):
                    print("Successfully added device token to database: \(successResponse.successReason)")
                case .failure(_):
                    print("Unable to enable push notifications. Please connect to the internet.")
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // If push notification registration is successful
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let newDeviceToken = tokenParts.joined()
        print("Device Token: \(newDeviceToken)")
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: Defaults.UserDefaults.isLoggedIn.rawValue)
        
        if isLoggedIn == true {
            
            let oldDeviceToken = UserDefaults.standard.string(forKey: Defaults.UserDefaults.deviceToken.rawValue)
            
            // Check if old token matches new token before sending to server
            if oldDeviceToken != newDeviceToken {
                // Save new token to user defaults
                UserDefaults.standard.set(newDeviceToken, forKey: Defaults.UserDefaults.deviceToken.rawValue)
                UserDefaults.standard.synchronize()
                self.sendDeviceTokenToServer(deviceToken: newDeviceToken)
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // If push notification registration fails
        print("Failed to register for remote notifications: \(error)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        // Called when user recieves a remote notification and the app is in the background or foreground
        guard
            let aps = userInfo["aps"] as? [String: AnyObject],
            let selectIndex = userInfo["selectIndex"] as? Int
        else {
            print("could not get aps dictionary - AppDelegate")
            return
        }

        // Check if this is a silent notification
        // If it is, then update the data in core data by doing a network request and saving to core data
        if aps["content-available"] as? Int == 1 {
            // Silent notification, so update data

            let sort = NSSortDescriptor(key: "id", ascending: false) // Sort with highest id as the first object in the array
            let context = PersistenceService.privateChildManagedObjectContext()

            if selectIndex == 1 {
                let endpoint = "/refreshAppointments.php"
                guard
                    let lastObjectId = PersistenceService.fetchEntity(Appointment.self, filter: nil, sort: [sort]).last?.id
                else {
                    print("could not get last object id - AppDelegate")
                    return
                }

                self.pushNotificationDataRefresh(endpoint: endpoint, lastObjectId: lastObjectId, objectType: [AppointmentModel].self, success: {
                        (appointments) in
                        // Save to core data
                    guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.appointment.rawValue, in: context) else { return }

                            for appointment in appointments {
                                if let coreDataAppointment = NSManagedObject(entity: entity, insertInto: context) as? Appointment {

                                    coreDataAppointment.address = appointment.address
                                    coreDataAppointment.companyId = Int32(appointment.companyId)
                                    coreDataAppointment.confirmed = appointment.confirmed
                                    coreDataAppointment.created = appointment.createdDate
                                    coreDataAppointment.dateOfBirth = appointment.dateOfBirthDate
                                    coreDataAppointment.email = appointment.email
                                    coreDataAppointment.gender = appointment.gender
                                    guard let id = appointment.id else { return }
                                    coreDataAppointment.id = Int32(id)
                                    coreDataAppointment.name = appointment.name
                                    coreDataAppointment.phoneNumber = appointment.phoneNumber
                                    coreDataAppointment.testType = appointment.testType
                                    coreDataAppointment.time = appointment.timeDate
                                    coreDataAppointment.timeZone = appointment.timeZone
                                    coreDataAppointment.unitType = appointment.unitType
                                    coreDataAppointment.city = appointment.city
                                    coreDataAppointment.zip = appointment.zip

                                }
                            }
                    
                            // Save objects to CoreData once they have been inserted into the context container
                            PersistenceService.saveContext(context: context)

                })

            } else if selectIndex == 2 {
                    let endpoint = "/refreshLeads.php"
                    guard
                        let lastObjectId = PersistenceService.fetchEntity(Lead.self, filter: nil, sort: [sort]).last?.id
                    else {
                        print("could not get last object id - AppDelegate")
                        return
                    }

                    self.pushNotificationDataRefresh(endpoint: endpoint, lastObjectId: lastObjectId, objectType: [LeadModel].self, success: {
                        (leads) in
                        // Save to core data
                        guard let entity = NSEntityDescription.entity(forEntityName: Defaults.CoreDataEntities.lead.rawValue, in: context) else { return }

                            for lead in leads {
                                if let coreDataLead = NSManagedObject(entity: entity, insertInto: context) as? Lead {

                                    guard let id = lead.id else { return }
                                    coreDataLead.id = Int32(id)
                                    coreDataLead.name = lead.name
                                    coreDataLead.phoneNumber = lead.phoneNumber
                                    coreDataLead.email = lead.email
                                    coreDataLead.dateOfInquiry = lead.dateOfInquiryDate
                                    coreDataLead.renterBrand = lead.renterBrand
                                    coreDataLead.companyId = Int32(lead.companyId)
                                    coreDataLead.sentTextDate = lead.sentTextDateDate
                                    coreDataLead.sentEmailDate = lead.sentEmailDateDate
                                    coreDataLead.filledOutForm = lead.filledOutForm
                                    coreDataLead.madeAppointment = lead.madeAppointment
                                    coreDataLead.companyName = lead.companyName

                                }
                            }
                        
                            // Save objects to CoreData once they have been inserted into the context container
                            PersistenceService.saveContext(context: context)
                        
                    })

            }

        } else {
            // Not a silent notification
            print("Not a silent notification")
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Notification arrives while app is running in foreground
        
    }

}

