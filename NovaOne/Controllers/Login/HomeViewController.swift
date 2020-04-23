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
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        lineChart.delegate = self
        self.getObjectCounts() {
            [weak self] in
            self?.setupGreetingLabel()
            self?.setupNumberLabels()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.setupLineChart()
    }
    
    func setupLineChart() {
        
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
        var dateComponents = DateComponents()
        dateComponents.year = 2020
        dateComponents.month = 7
        dateComponents.day = 11
        dateComponents.timeZone = TimeZone(abbreviation: "America/New_York")
        dateComponents.hour = 8
        dateComponents.minute = 23
        
        let calendar = Calendar.current
        let date1 = calendar.date(from: dateComponents)
        
        dateComponents.day = 18
        let date2 = calendar.date(from: dateComponents)
        
        dateComponents.day = 31
        let date3 = calendar.date(from: dateComponents)
        
        let chartValues = [ChartValuesWithDateAsXAxis(x: date1!, y: 4.0), ChartValuesWithDateAsXAxis(x: date2!, y: 2.0), ChartValuesWithDateAsXAxis(x: date3!, y: 8.0)]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E d"
        
        let xValuesNumberFormatter = ChartXAxisFormatter(dateFormatter: formatter)
        lineChart.xAxis.valueFormatter = xValuesNumberFormatter
        
        
        // Add chart view to chart container view
        self.chartContainerView.addSubview(lineChart)
        
        // Create data entries
        var entries = [ChartDataEntry]()
        for chartValue in chartValues {
            let xValue = chartValue.x.timeIntervalSince1970
            let yValue = chartValue.y
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
    
    func getObjectCounts(success: @escaping () -> Void) {
        // Gets the number of a chosen object from the database
        
        self.showSpinner(for: self.view) // Show the loading screen
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: "password")
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/objectCounts.php", dataModel: [ObjectCount].self, parameters: parameters) {
            [weak self] (result) in
            
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
            
            self?.removeSpinner()
            
        }
    }
    
    // MARK: Actions
    @IBAction func numberOfLeadsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 3
    }

}
