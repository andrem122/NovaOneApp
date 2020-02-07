//
//  HTTPRequests.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/30/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation


// Send HTTP requests to given url
class HTTPRequests {
    
    
    // MARK: Properties
    let url: String
    
    init(url: String) {
        self.url = url
    }
    
    // Send POST requests
    func post(parameters: [String: Any], completion: @escaping (String, Data?) -> Void) {
        
        if let url = URL(string: self.url) {
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = parameters.percentEncoded() // Percent encode url string. Example: Jack & Jill becomes Jack%20%26%20Jill
            
            let task = URLSession.shared.dataTask(with: request) {
                (data, response, error) in
                
                // Check for fundamental networking error
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    print(error ?? "Unknown error occurred")
                    return
                }
                
                // Check for HTTP errors
                // Password incorrect or username not found or some other error occured
                guard (200...299) ~= response.statusCode else {
                    
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    let responseString = String(data: data, encoding: String.Encoding.utf8)!
                    completion(responseString, nil)
                    return
                    // Put responseString in a callback function 'completion' that you can call by:
                    // class.method() {
                    //   (responseString) in
                    //   // rest of function login here...
                    // }
                    
                }
                
                // Login successful convert JSON string type to JSON data object type
                if let jsonString = String(data: data, encoding: String.Encoding.utf8) {
                    let jsonData: Data = jsonString.data(using: .utf8)!
                    completion(jsonString, jsonData)
                }
                
            }
            
            task.resume()
            
        }
        
    }
    
    // Make HTTP request
    func request(endpoint: String,
                 parameters: [String: Any],
                 completion: @escaping (Result<CustomerModel, Error>) -> Void) {
        
        // Convert url string to URL type
        guard let url: URL = URL(string: self.url + endpoint) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        var components: URLComponents = URLComponents()
        var queryItems: [URLQueryItem] = []
        
        // Create URL query items from paramters dictionary
        for (key, value) in parameters {
            let queryItem: URLQueryItem = URLQueryItem(name: key, value: String(describing: value))
            queryItems.append(queryItem)
        }
        
        components.queryItems = queryItems
        
        // Convert query property string (a string that looks like name=Tom&password=266631Asd&height=fiveseven) to Data type
        let queryItemData: Data? = components.query?.data(using: .utf8)
        
        // Set request properties
        request.httpBody = queryItemData
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        // Create datatask to retrieve information from the internet
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            
            DispatchQueue.main.async { // Run on main thread instead of background thread
                
                // Unwrap response object and check url
                guard let unwrappedResponse = response as? HTTPURLResponse else {
                    completion(.failure(NetworkingError.badResponse))
                    return
                }
                
                // Errors
                if let unwrappedError = error {
                    completion(.failure(unwrappedError))
                    return // if there is an error (usually with a internet connection)
                           //return and do nothing
                }
                
                // Try to decode JSON data into a swift data object and catch any errors if
                // it can not be done
                if let unwrappedData = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                        print(json)
                    } catch {
                        print(String(data: unwrappedData, encoding: .utf8) ?? "No Data")
                        completion(.failure(error)) // error variable is given to us by default
                                                    // in the catch block
                    }
                }
                
                switch unwrappedResponse.statusCode {
                    
                    case 200..<300: // up to but NOT including 300
                        print("Success")
                    default:
                        print("Failure")
                    
                }
                
            }
            
        }
        
        task.resume() // Set out task to the internet by calling method resume otherwise no request will be made
        
        
    }
    
}

enum NetworkingError: Error {
    case badUrl
    case badResponse
}

extension Dictionary {
    
    func percentEncoded() -> Data? {
        
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
    
}

extension CharacterSet {
    
    static let urlQueryValueAllowed: CharacterSet = {
        
        let generalDelimitersToEncode: String = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode: String = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
        
    }()
    
}
