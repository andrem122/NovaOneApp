//
//  HelpTableViewController.swift
//  NovaOne
//
//  Created by Andre Mashraghi on 4/13/20.
//  Copyright © 2020 Andre Mashraghi. All rights reserved.
//

import UIKit
import SafariServices

class HelpTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let section = indexPath.section
        if section == 1 {
            switch indexPath.row {
                case 0: // Terms
                    
                    guard let url = URL(string: Defaults.Urls.novaOneWebsite.rawValue) else { return }
                    let webViewController = SFSafariViewController(url: url)
                    self.present(webViewController, animated: true, completion: nil)
                    
                case 1: // Privacy
                    
                    guard let url = URL(string: Defaults.Urls.novaOneWebsite.rawValue) else { return }
                    let webViewController = SFSafariViewController(url: url)
                    self.present(webViewController, animated: true, completion: nil)
                    
                default:
                    print("No cases matched")
            }
        }
    }


}
