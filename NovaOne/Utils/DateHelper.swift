//
//  DateHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 3/7/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation

// A class of commonly used functions for manipulating dates
class DateHelper {
    
    // MARK: Properties
    static let now: Date = Date()
    
    // MARK: Methods
    // Converts string of a given format to a Date object
    static func createDate(from dateString: String, format: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        guard let date = dateFormatter.date(from: dateString) else { return self.now }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        guard let finalDate = calendar.date(from: components) else { return self.now }
        
        return finalDate
    }
    
}
