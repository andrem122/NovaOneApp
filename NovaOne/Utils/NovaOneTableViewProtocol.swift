//
//  NovaOneTableView.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 5/23/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import CoreData
import SkeletonView

protocol NovaOneTableView {
    // MARK: Properties
    var timer: Timer? { get set }
    var parentViewContainerController: UIViewController? { get set }
    var customer: CustomerModel? { get set }
    var bottomTableViewSpinner: UIActivityIndicatorView? { get set }
    var tableIsRefreshing: Bool { get set }
    var appendingDataToTable: Bool { get set }
    var objects: [NSManagedObject] { get set }
    var filteredObjects: [NSManagedObject] { get set }
    var searchController: UISearchController! { get set }
    var alertService: AlertService { get set }
    var refresher: UIRefreshControl { get set }
    
    // MARK: Methods
    
    // UIViewController Methods
    func viewWillAppear(_ animated: Bool)
    func viewWillDisappear(_ animated: Bool)
    
    // Setup functions
    func setupTableView()
    func setupSearch()
    func getCoreData()
    
    // Animation functions
    func hideTableLoadingAnimations()
    
    // Data functions
    func saveObjectsToCoreData(objects: [Decodable])
    func getData(endpoint: String, append: Bool, lastObjectId: Int32?, completion: (() -> Void)?)
    
    // Refresh data functions
    func setTimerForTableRefresh()
    func refreshDataAutomatically()
    func refreshDataOnPullDown()
    
    // Table View Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    
    // MARK: Navigation
    func prepare(for segue: UIStoryboardSegue, sender: Any?)
    
    // MARK: Actions
    func addButtonTapped(_ sender: Any)
    
    // Searching
    func updateSearchResults(for searchController: UISearchController)
    
    // Skeleton View
    func collectionSkeletonView(_ skeletonView: UITableView, cellIdentifierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier
}
