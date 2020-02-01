//
//  HomeModel.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/29/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

protocol HomeModelProtocol: class {
    func itemsDownloaded(items: NSArray)
}

class HomeModel: NSObject, URLSessionDataDelegate {
    
    // MARK: Properties
    weak var delegate: HomeModelProtocol!
    var data = Data()
    let urlPath: String = "https://graystonerealtyfl.com/NovaOne/login.php"
    
    // MARK: Methods
    func parseJSON(data: Data) {
        
        var jsonResult = NSArray()
        
        do {
            jsonResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSArray
        } catch let error as NSError {
            print(error)
        }
        
        var jsonElement = NSDictionary()
        let userDetailsMulti = NSMutableArray()
        
        for i in 0 ..< jsonResult.count {
            jsonElement = jsonResult[i] as! NSDictionary
            let customer: CustomerModel = CustomerModel()
            
            if let email = jsonElement["email"] as? String,
                let id = jsonElement["id"] as? String,
                let firstName = jsonElement["firstName"] as? String,
                let lastName = jsonElement["lastName"] as? String,
                let address = jsonElement["address"] as? String,
                let dateJoinedString = jsonElement["dateJoinedString"] as? String,
                let primaryPhone = jsonElement["primaryPhone"] as? String {
                
                // Set customer properties
                customer.id = Int(id)
                customer.email = email
                customer.propertyAddress = address
                customer.firstName = firstName
                customer.lastName = lastName
                customer.customerPhone = primaryPhone
                customer.dateJoinedString = dateJoinedString
                
            }
            
            userDetailsMulti.add(customer)
        }
        
        DispatchQueue.main.async(execute: {
            () -> Void in
            self.delegate.itemsDownloaded(items: userDetailsMulti)
        })
        
    }
    
    func downloadItems() {
        
        // Put our urlPath string into the URL class to convert it to a URL object for use
        // in the URLSession.dataTask method
        let url: URL = URL(string: urlPath)!
        let defaultSession = Foundation.URLSession(configuration: URLSessionConfiguration.default) // Start the URL session
        
        // Retrieve the JSON data from the given url
        let task = defaultSession.dataTask(with: url) {
            (data, response, error) in
            if error != nil {
                print("Failed to download data.")
            } else {
                print("Data has been downloaded.")
                self.parseJSON(data: data!)
            }
        }
        
        task.resume()
        
    }
    
}
