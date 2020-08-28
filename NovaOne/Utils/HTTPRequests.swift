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
    
    func handleResponse<DataModel: Decodable>(for request: URLRequest,
                                              dataModel: DataModel.Type,
                                   completion: @escaping (Result<DataModel, Error>) -> Void) -> Void {
        
        // Create datatask to retrieve information from the internet
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 10.0
        sessionConfig.timeoutIntervalForResource = 10.0
        let session = URLSession(configuration: sessionConfig)
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
                    print(String(data: unwrappedData, encoding: .utf8)!)
                    do {
                        
                        // Convert to JSON swift objectmto see if the data response from the server is valid JSON
                        // catch the error in thr catch block if the data can not e converted to a JSON object
                        // in swift
                        let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                        print(json)
                        
                        
                        // Try to convert to customer object from JSON data
                        if let object = try? JSONDecoder().decode(DataModel.self, from: unwrappedData) {
                            
                            completion(.success(object)) // Pass object to result enumeration as an associated value
                            
                        } else {
                            
                            // Since our try has a question mark (try?), it will run this code in the 'else'
                            // block and make our error become nil if something in the 'do' block fails
                            
                            // If we can not convert the data response to a customer object, convert it
                            // to an error object. If we can not convert to an error object, the catch block
                            // will run and show us the error
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: unwrappedData)
                            completion(.failure(errorResponse))
                            
                        }
                        
                    } catch {
                        
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
    
    // Make HTTP request
    // DataModel could be and data model that confroms to the Decodable protocol
    func request<DataModel: Decodable>(url: String,
                                       dataModel: DataModel.Type,
                            parameters: [String: Any],
                            completion: @escaping (Result<DataModel, Error>) -> Void) {
        
        // Add PHP credentials to parmaters array
        var mutatedParamaters: [String: Any] = parameters // any argument into a swift function is immutable (can not be changed), so set it to a variable (can be changed or mutable)
        mutatedParamaters["PHPAuthenticationUsername"] = Defaults.PHPAuthenticationUsername
        mutatedParamaters["PHPAuthenticationPassword"] = Defaults.PHPAuthenticationPassword
        
        // Percent encode the values in the dictionary if it is of type String
        for (key, value) in mutatedParamaters {
            // If we can typecast the paramater value into a string, then percent encode it
            if let valueAsString = value as? String {
                guard let percentEncodedString = valueAsString.addingPercentEncodingForRFC3986() else {
                    print("could not percent encode string - UpdateBaseViewController")
                    return
                }
                
                // Replace string value in dictionary with percent encoded string
                mutatedParamaters[key] = percentEncodedString
            }
        }
        
        // Convert url string to URL type
        guard let url: URL = URL(string: url) else {
            completion(.failure(NetworkingError.badUrl))
            return
        }
        
        var request: URLRequest = URLRequest(url: url)
        var components: URLComponents = URLComponents()
        var queryItems: [URLQueryItem] = []
        
        // Create URL query items from paramters dictionary
        for (key, value) in mutatedParamaters {
            let queryItem: URLQueryItem = URLQueryItem(name: key, value: String(describing: value))
            queryItems.append(queryItem)
        }
        
        components.queryItems = queryItems
        request.setValue("https://www.novaonesoftware.com", forHTTPHeaderField: "Referer")
        
        // Convert query property string (a string that looks like name=Tom&password=266631Asd&height=fiveseven) to Data type
        let queryItemData: Data? = components.query?.data(using: .utf8)
        
        // Set request properties
        request.httpBody = queryItemData
        request.httpMethod = "POST"
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        self.handleResponse(for: request, dataModel: dataModel, completion: completion)
        
    }
    
}

enum NetworkingError: Error {
    case badUrl
    case badResponse
    case badEncoding
}
