//
//  UserLoggedInStartViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 1/31/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData
import Charts

class HomeViewController: UIViewController, ChartViewDelegate {

    // MARK: Properties
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var numberOfLeadsLabel: UILabel!
    @IBOutlet weak var numberOfAppointmentsLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    var lineChart = LineChartView()
    var lineChartValues = [ChartValuesWithDateAsXAxis]()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getObjectCounts() {
            [weak self] in
            self?.setupGreetingLabel()
            self?.setupNumberLabels()
            self?.getChartData() {
                self?.setupLineChart()
            }
        }
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        self.setupLineChart()
//    }
    
    func setupLineChart() {
        lineChart.delegate = self
        // Setup frame of chart
        let width = self.chartContainerView.bounds.width
        let height = self.chartContainerView.bounds.height
        
        lineChart.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        // Set colors
        let colors = [Defaults.novaOneColor]
        lineChart.gridBackgroundColor = .white
        
        // Set grid style
        
        // For X axis
        lineChart.xAxis.labelPosition = .bottom
        lineChart.xAxis.drawGridLinesEnabled = false // remove x grid lines behind data
        lineChart.xAxis.drawAxisLineEnabled = false // remove axis line and leave only numbers
        lineChart.leftAxis.enabled = false // remove the left x axis
        
        // For Y axis
        lineChart.rightAxis.labelPosition = .insideChart
        lineChart.rightAxis.drawGridLinesEnabled = false
        lineChart.rightAxis.drawAxisLineEnabled = false
        
        // Setup x axis values to have a date string as the x-axis
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
        
        let xValuesNumberFormatter = ChartXAxisFormatter(dateFormatter: formatter)
        lineChart.xAxis.valueFormatter = xValuesNumberFormatter
        //lineChart.xAxis.setLabelCount(7, force: true)
        
        
        // Add chart view to chart container view
        self.chartContainerView.addSubview(lineChart)
        
        // Create data entries
        var entries = [ChartDataEntry]()
        for lineChartValue in self.lineChartValues {
            let xValue = lineChartValue.x.timeIntervalSince1970
            let yValue = lineChartValue.y
            let entry = ChartDataEntry(x: xValue, y: yValue)
            entries.append(entry)
        }
        
        let set = LineChartDataSet(entries: entries)
        set.colors = colors
        set.label = "Leads" // The title next to the data set
        set.drawCirclesEnabled = false
        
        let gradientColors = [Defaults.novaOneColor.cgColor, UIColor.clear.cgColor] as CFArray // Colors of the gradient
        let colorLocations:[CGFloat] = [1.0, 0.0] // Positioning of the gradient
        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: colorLocations) // Gradient Object
        set.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0) // Set the Gradient
        set.drawFilledEnabled = true // Draw the Gradient
        
        let data = LineChartData(dataSet: set)
        lineChart.data = data
    }
    
    func setupGreetingLabel() {
        
        // Get current day of the week
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let weekDay = dateFormatter.string(from: currentDate)
        
        // Set greeting label text
        guard let customer = PersistenceService.fetchCustomerEntity() else { return }
        
        guard let firstName = customer.firstName else { return }
        let leadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.leadCount.rawValue)
        let greetingString = "Hello \(firstName), it's \(weekDay),\nand you have \(leadCount) leads."
        self.greetingLabel.text = greetingString
        
    }
    
    func setupNumberLabels() {
        // Setup labels
        
        let leadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.leadCount.rawValue)
        let appointmentCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.appointmentCount.rawValue)
        self.numberOfLeadsLabel.text = String(leadCount)
        self.numberOfAppointmentsLabel.text = String(appointmentCount)
        
        // Add gesture recognizers, so that when the labels are tapped, something happens
        let tap = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.numberOfLeadsLabelTapped))
        self.numberOfLeadsLabel.isUserInteractionEnabled = true
        self.numberOfLeadsLabel.addGestureRecognizer(tap)
        
    }
    
    func getChartData(success: @escaping () -> Void) {
        // Gets chart data from the database
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/chartData.php", dataModel: [LineChartDataModel].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let lineChartData):
                    let startDate = lineChartData[0].dateDate.timeIntervalSince1970
                    let calendar = Calendar.current
                    
                    // Bind data to a variable
                    for number in 0..<7 { // We want 7 days of data points to represent a week of data
                        
                        var count = 0.0 // Set count to zero for the day as default
                        var date: Date = Date(timeIntervalSince1970: Double(number) * 3600 * 24 + startDate) // add n number of days to the start date
                        
                        for lineData in lineChartData {
                            let dateComponentsFromData = calendar.dateComponents([.year, .month, .day], from: lineData.dateDate)
                            let dateComponentsFromDate = calendar.dateComponents([.year, .month, .day], from: date)
                            
                            if dateComponentsFromData.day == dateComponentsFromDate.day {
                                count = Double(lineData.count)
                                date = lineData.dateDate
                            }
                        }
                        
                        print("Count: \(count), Date: \(date)")
                        
                        let chartValuesWithDateAsXAxis = ChartValuesWithDateAsXAxis(x: date, y: count)
                        self?.lineChartValues.append(chartValuesWithDateAsXAxis)
                    }
                    success()
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
            self?.removeSpinner()
            
        }
    }
    
    func getObjectCounts(success: @escaping () -> Void) {
        // Gets the number of a chosen object from the database
        
        self.showSpinner(for: self.view)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/objectCounts.php", dataModel: [ObjectCountModel].self, parameters: parameters) {
            (result) in
            
            switch result {
                case .success(let objectCounts):
                    for objectCount in objectCounts {
                        // Save to user defaults for later use
                        UserDefaults.standard.set(objectCount.count, forKey: objectCount.name)
                    }
                    
                    // Run the success completion handler
                    success()
                case .failure(let error):
                    print(error.localizedDescription)
            }
            
        }
    }
    
    // MARK: Actions
    @IBAction func numberOfLeadsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }

}
