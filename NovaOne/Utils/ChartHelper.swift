//
//  ChartHelper.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/22/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import Foundation
import Charts

class ChartXAxisFormatter: NSObject {
    // Formats the x axis for charts
    var xLabels: [String]?
    
    init(xLabels: [String]) {
        self.xLabels = xLabels
    }
    
}

extension ChartXAxisFormatter: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        // Return a string value for every x value inserted into a ChartDataEntry object
        guard
            let xLabels = self.xLabels
        else { return "" }
        
        let stringForValue = xLabels[Int(value)]
        return stringForValue
    }
    
}
