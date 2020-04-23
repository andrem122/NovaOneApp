//
//  ChartHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/22/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
import Charts

class ChartXAxisFormatter {
    // Formats the x axis for charts
    fileprivate var dateFormatter: DateFormatter? // fileprivate means this property is only accessible from the same source where it was declared
    
    init(dateFormatter: DateFormatter) {
        self.dateFormatter = dateFormatter
    }
    
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // Return a string value for every x value inserted into a ChartDataEntry object
        guard
            let dateFormatter = self.dateFormatter
        else { return "" }
        
        let date = Date(timeIntervalSince1970: value)
        return dateFormatter.string(from: date)
    }
    
}
