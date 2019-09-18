//
//  ThemedTableViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-07.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ThemedTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "background")
        tableView.separatorColor = UIColor(named: "tableViewSeparator")

    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = UIColor(named: "contentTitle")
        cell.detailTextLabel?.textColor = UIColor(named: "contentSubtitle")
    }
    
}
