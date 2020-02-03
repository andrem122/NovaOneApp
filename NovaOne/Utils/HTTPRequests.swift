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
