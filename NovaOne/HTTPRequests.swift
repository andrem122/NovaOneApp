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
    func post(parameters: [String: Any]) {
        
        if let url = URL(string: self.url) {
            
            var request = URLRequest(url: url)
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = parameters.percentEncoded() // Percent encode url string. Example: Jack & Jill becomes Jack%20%26%20Jill
            
            let task = URLSession.shared.dataTask(with: request) {
                data, response, error in
                
                // Check for fundamental networking error
                guard let data = data, let response = response as? HTTPURLResponse, error == nil else {
                    print(error ?? "Unknown error occurred")
                    return
                }
                
                // Check for HTTP errors
                guard (200...299) ~= response.statusCode else {
                    print("statusCode should be 2xx, but is \(response.statusCode)")
                    print("response = \(response)")
                    return
                }
                
                let responseString: String? = String(data: data, encoding: .utf8)
                
                if let responseString = responseString {
                    print("responseString = \(responseString)")
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
