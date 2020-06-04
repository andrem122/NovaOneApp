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
import SkeletonView

class HomeViewController: BaseLoginViewController, ChartViewDelegate {

    // MARK: Properties
    @IBOutlet weak var graphView: UIView!
    @IBOutlet weak var greetingLabel: UILabel!
    @IBOutlet weak var numberOfLeadsLabel: UILabel!
    @IBOutlet weak var numberOfAppointmentsLabel: UILabel!
    @IBOutlet weak var numberOfCompaniesLabel: UILabel!
    @IBOutlet weak var chartContainerView: UIView!
    @IBOutlet weak var ipadChartContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var chartTitle: UILabel!
    let alertService = AlertService()
    var barChart = BarChartView()
    var lineChart = LineChartView()
    var barChartEntries = [BarChartDataEntry]()
    var lineChartEntries  = [ChartDataEntry]()
    var barChartXLabels = [String]()
    var lineChartXLabels = [String]()
    
    // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.showAnimatedGradientSkeleton()
        self.setupNavigationBar(for: self, navigationBar: nil, navigationItem: nil)
        barChart.delegate = self
        self.getObjectCounts() {
            [weak self] in
            self?.view.hideSkeleton()
            self?.setupGreetingLabel()
            self?.setupNumberLabels()
        }
        self.getWeeklyChartData {
            [weak self] in
            self?.setupBarChart()
        }
        self.getMonthChartData {
            [weak self] in
            self?.setupLineChart()
        }
    }
    
    func setupLineChart() {
        // Add charts view to chart container views
        self.ipadChartContainerView.addSubview(self.lineChart)
        
        let noDataText = "No data available"
        self.lineChart.noDataText = noDataText
        self.lineChart.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            self.lineChart.leftAnchor.constraint(equalTo: self.ipadChartContainerView.leftAnchor),
            self.lineChart.rightAnchor.constraint(equalTo: self.ipadChartContainerView.rightAnchor),
            self.lineChart.topAnchor.constraint(equalTo: self.ipadChartContainerView.topAnchor),
            self.lineChart.bottomAnchor.constraint(equalTo: self.ipadChartContainerView.bottomAnchor)
        ])
        
        // Set colors
        let colors = [Defaults.novaOneColor]
        self.lineChart.gridBackgroundColor = .white
        
        // Set grid style
        // For X axis
        self.lineChart.xAxis.labelPosition = .bottom
        self.lineChart.xAxis.drawGridLinesEnabled = false // remove x grid lines behind data
        self.lineChart.xAxis.drawAxisLineEnabled = false // remove axis line and leave only numbers
        self.lineChart.leftAxis.enabled = false // remove the left x axis
        self.lineChart.xAxis.granularityEnabled = true
        self.lineChart.xAxis.granularity = 1.0
        self.lineChart.xAxis.labelCount = self.lineChartEntries.count
        
        // For Y axis
        self.lineChart.rightAxis.labelPosition = .outsideChart
        self.lineChart.rightAxis.drawGridLinesEnabled = false
        self.lineChart.rightAxis.drawAxisLineEnabled = false
        
        // Disable zooming
        self.lineChart.scaleYEnabled = false
        self.lineChart.scaleXEnabled = false
        self.lineChart.setScaleEnabled(false)
        
        // Animation
        self.lineChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Setup x axis values to have a date string as the x-axis
        let xValuesNumberFormatter = ChartXAxisFormatter(xLabels: self.lineChartXLabels) // Plug in x values into our custom XAxisFormatter class
        self.lineChart.xAxis.valueFormatter = xValuesNumberFormatter
        
        // Create data set from entries
        let set = LineChartDataSet(entries: self.lineChartEntries)
        set.circleColors = colors
        set.lineWidth = 2
        set.colors = colors
        set.label = "Appointments" // The title next to the data set
        
        let data = LineChartData(dataSet: set)
        
        if !self.lineChartEntries.isEmpty {
            lineChart.data = data
        } else {
            lineChart.data = nil
        }
        
        self.lineChart.notifyDataSetChanged()
    }
    
    func setupBarChart() {
        // Add charts view to chart container views
        self.chartContainerView.addSubview(self.barChart)
        
        let noDataText = "No data available"
        self.barChart.noDataText = noDataText
        self.barChart.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            self.barChart.leftAnchor.constraint(equalTo: self.chartContainerView.leftAnchor),
            self.barChart.rightAnchor.constraint(equalTo: self.chartContainerView.rightAnchor),
            self.barChart.topAnchor.constraint(equalTo: self.chartContainerView.topAnchor),
            self.barChart.bottomAnchor.constraint(equalTo: self.chartContainerView.bottomAnchor)
        ])
        
        // Set colors
        let colors = [Defaults.novaOneColor]
        self.barChart.gridBackgroundColor = .white
        
        // Set grid style
        // For X axis
        self.barChart.xAxis.labelPosition = .bottom
        self.barChart.xAxis.drawGridLinesEnabled = false // remove x grid lines behind data
        self.barChart.xAxis.drawAxisLineEnabled = false // remove axis line and leave only numbers
        self.barChart.leftAxis.enabled = false // remove the left x axis
        self.barChart.xAxis.granularityEnabled = true
        self.barChart.xAxis.granularity = 1.0
        self.barChart.xAxis.labelCount = self.barChartEntries.count
        
        // For Y axis
        self.barChart.rightAxis.labelPosition = .outsideChart
        self.barChart.rightAxis.drawGridLinesEnabled = false
        self.barChart.rightAxis.drawAxisLineEnabled = false
        
        // Disable zooming
        self.barChart.scaleYEnabled = false
        self.barChart.scaleXEnabled = false
        self.barChart.setScaleEnabled(false)
        
        // Animation
        self.barChart.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        
        // Setup x axis values to have a date string as the x-axis
        let xValuesNumberFormatter = ChartXAxisFormatter(xLabels: self.barChartXLabels) // Plug in x values into our custom XAxisFormatter class
        self.barChart.xAxis.valueFormatter = xValuesNumberFormatter
        
        // Create data set from entries
        let set = BarChartDataSet(entries: self.barChartEntries)
        set.colors = colors
        set.label = "Leads" // The title next to the data set
        
        let data = BarChartData(dataSet: set)
        
        if !self.barChartEntries.isEmpty {
            barChart.data = data
        } else {
            barChart.data = nil
        }
        
        self.barChart.notifyDataSetChanged()
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
        let greetingString = "Hello \(firstName), it's \(weekDay), and you have \(leadCount) leads."
        self.greetingLabel.text = greetingString
        
    }
    
    func addGestureRecognizer(to label: UILabel, selector: Selector) {
        let tap = UITapGestureRecognizer(target: self, action: selector)
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tap)
    }
    
    func setupNumberLabels() {
        // Setup labels
        
        let leadCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.leadCount.rawValue)
        let appointmentCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.appointmentCount.rawValue)
        let companyCount = UserDefaults.standard.integer(forKey: Defaults.UserDefaults.companyCount.rawValue)
        
        self.numberOfLeadsLabel.text = String(leadCount)
        self.numberOfAppointmentsLabel.text = String(appointmentCount)
        self.numberOfCompaniesLabel.text = String(companyCount)
        
        // Add gesture recognizers, so that when the labels are tapped, something happens
        self.addGestureRecognizer(to: self.numberOfLeadsLabel, selector: #selector(HomeViewController.numberOfLeadsLabelTapped))
        self.addGestureRecognizer(to: self.numberOfAppointmentsLabel, selector: #selector(HomeViewController.numberOfAppointmentsLabelTapped))
        self.addGestureRecognizer(to: self.numberOfCompaniesLabel, selector: #selector(HomeViewController.numberOfCompaniesLabelTapped))
        
    }
    
    func getWeeklyChartData(completion: (() -> Void)?) {
        // Gets chart data from the database
        
        self.showSpinner(for: self.chartContainerView, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/chartDataWeekly.php", dataModel: [ChartDataWeeklyModel].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let chartData):
                    // Remove all previous data from the entries and x labels array
                    self?.barChartEntries.removeAll()
                    self?.barChartXLabels.removeAll()
                    
                    guard let startDate = (chartData.map {$0.dateDate}).min() else { return }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "E\nd"
                    let calendar = Calendar.current
                    var dateComponent = DateComponents()
                    
                    // Bind data to a variable
                    for number in 0..<7 { // We want 7 days of data points to represent a week of data
                        
                        var count = 0.0 // Set count to zero for the day as default
                        
                        dateComponent.day = number // Add n number of days to the start date
                        guard var date = calendar.date(byAdding: dateComponent, to: startDate) else { return }
                        
                        for data in chartData {
                            let dateComponentsFromData = calendar.dateComponents([.year, .month, .day], from: data.dateDate)
                            let dateComponentsFromDate = calendar.dateComponents([.year, .month, .day], from: date)
                            
                            if dateComponentsFromData.day == dateComponentsFromDate.day {
                                count = Double(data.count)
                                date = data.dateDate
                            }
                        }
                        
                        // Add to x labels array
                        let dateString = dateFormatter.string(from: date)
                        self?.barChartXLabels.append(dateString)
                        
                        let chartEntry = BarChartDataEntry(x: Double(number), y: count)
                        self?.barChartEntries.append(chartEntry)
                    }
            
                case .failure(let error):
                    self?.showPopUpOk(error: error)
            }
            
            guard let unwrappedCompletion = completion else { return }
            unwrappedCompletion()
            self?.removeSpinner()
            
        }
    }
    
    func getMonthlyChartData(completion: (() -> Void)?) {
        // Gets chart data from the database
        
        self.showSpinner(for: self.chartContainerView, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/chartDataMonthly.php", dataModel: [ChartDataMonthlyModel].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let chartData):
                    // Remove all previous data from the entries and x labels array
                    self?.barChartEntries.removeAll()
                    self?.barChartXLabels.removeAll()
                    
                    let dateFormatter = DateFormatter()
                    let calendar = Calendar.current
                    
                    let currentDate = Date()
                    guard let startDate = calendar.date(byAdding: .year, value: -1, to: currentDate) else { return } // Get date from one year ago as starting point and add 1 month during each loop
                    
                    // Bind data to a variables
                    for number in 0..<12 { // We want 12 months of data points to represent a year of data
                        
                        var count = 0.0 // Set count to zero for the month as default
                        guard let date = calendar.date(byAdding: .month, value: number, to: startDate) else { return }
                        
                        dateFormatter.dateFormat = "MMM"
                        let monthFromDate = dateFormatter.string(from: date) // Returns shorthand of month Ex: 'Apr'
                        
                        dateFormatter.dateFormat = "yyyy"
                        let yearFromDate = dateFormatter.string(from: date) // Returns year as yyyy Ex: '2020'
                        
                        let dateString = "\(monthFromDate)\n\(yearFromDate)" // Returns with month then year Ex: 'Apr 2020'
                        
                        for data in chartData {
                            
                            let monthFromData = data.month
                            let yearFromData = data.year
                            
                            if monthFromData == monthFromDate && yearFromDate == yearFromData {
                                count = Double(data.count) // Change count from zero to the number in the data
                            }
                            
                            
                        }
                        
                        // Add to x labels array
                        self?.barChartXLabels.append(dateString)
                        
                        let chartEntry = BarChartDataEntry(x: Double(number), y: count)
                        self?.barChartEntries.append(chartEntry)
                    }
                    
                case .failure(let error):
                    // Update chart data
                    self?.barChart.data = nil
                    self?.barChart.notifyDataSetChanged()
                    self?.showPopUpOk(error: error)
            }
            
            guard let unwrappedCompletion = completion else { return }
            unwrappedCompletion()
            self?.removeSpinner()
            
        }
    }
    
    func getMonthChartData(completion: (() -> Void)?) {
        // Gets chart data from the database
        
        self.showSpinner(for: self.ipadChartContainerView, textForLabel: nil)
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/chartDataMonth.php", dataModel: [ChartDataMonthModel].self, parameters: parameters) {
            [weak self] (result) in
            
            switch result {
                case .success(let chartData):
                    // Remove all previous data from the entries and x labels array
                    self?.lineChartEntries.removeAll()
                    self?.lineChartXLabels.removeAll()
                    
                    // Bind data to a variables
                    for (index, data) in chartData.enumerated() {
                        let dateString = DateHelper.createString(from: data.dateDate, format: "MMM\ndd") // Returns with month then day Ex: 'Apr 21'

                        // Add to x labels array
                        self?.lineChartXLabels.append(dateString)

                        let chartEntry = ChartDataEntry(x: Double(index), y: Double(data.count))
                        self?.lineChartEntries.append(chartEntry)
                    }
                    
                case .failure(let error):
                    // Update chart data
                    self?.lineChart.data = nil
                    self?.lineChart.notifyDataSetChanged()
                    self?.showPopUpOk(error: error)
            }
            
            guard let unwrappedCompletion = completion else { return }
            unwrappedCompletion()
            self?.removeSpinner()
            
        }
    }
    
    func getObjectCounts(success: @escaping () -> Void) {
        // Gets the number of a chosen object from the database
        
        let httpRequest = HTTPRequests()
        guard
            let customer = PersistenceService.fetchEntity(Customer.self, filter: nil, sort: nil).first,
            let email = customer.email,
            let password = KeychainWrapper.standard.string(forKey: Defaults.KeychainKeys.password.rawValue)
        else { return }
        let customerUserId = customer.id
        
        let parameters: [String: Any] = ["email": email as Any, "password": password as Any, "customerUserId": customerUserId as Any]
        httpRequest.request(endpoint: "/objectCounts.php", dataModel: [ObjectCountModel].self, parameters: parameters) {
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
                    self?.showPopUpOk(error: error)
            }
            
        }
    }
    
    func showPopUpOk(error: Error) {
        // Shows the pop up ok view controller with a message and title
        
        if error.localizedDescription != Defaults.ErrorResponseReasons.noData.rawValue {
            // Set text for pop up ok view controller
            let title = "Error"
            let body = error.localizedDescription
            
            let popUpOkViewController = self.alertService.popUpOk(title: title, body: body)
            self.present(popUpOkViewController, animated: true, completion: nil)
        }
    }
    
    // MARK: Actions
    @IBAction func numberOfLeadsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 2 // Leads view
    }
    
    @IBAction func numberOfAppointmentsLabelTapped(sender: UITapGestureRecognizer) {
        self.tabBarController?.selectedIndex = 1 // Appointments view
    }
    
    @IBAction func numberOfCompaniesLabelTapped(sender: UITapGestureRecognizer) {
        
        self.tabBarController?.selectedIndex = 3 // Account view
        guard let accountTableViewController = self.tabBarController?.viewControllers?[3] as? UITableViewController else { return }
        guard let companiesContainerViewController = self.storyboard?.instantiateViewController(withIdentifier: Defaults.ViewControllerIdentifiers.companiesContainer.rawValue) as? CompaniesContainerViewController else { return }

        accountTableViewController.navigationController?.pushViewController(companiesContainerViewController, animated: true)
        
    }
    
    
    @IBAction func segmentControlValueChanged(_ sender: Any) {
        let title = self.segmentControl.titleForSegment(at: self.segmentControl.selectedSegmentIndex)
        
        self.barChart.removeFromSuperview()
        if title == "Month" {
            self.chartTitle.text = "Leads Per Month"
            self.getMonthlyChartData() {
                [weak self] in
                self?.setupBarChart()
            }
        } else {
            self.chartTitle.text = "Leads Per Week"
            self.getWeeklyChartData() {
                [weak self] in
                self?.setupBarChart()
            }
        }
    }
    
}
