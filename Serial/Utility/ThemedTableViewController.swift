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
        tableView.backgroundColor = #colorLiteral(red: 0.1450980392, green: 0.1529411765, blue: 0.2, alpha: 1)
        tableView.separatorColor = #colorLiteral(red: 0.2634820242, green: 0.2633357335, blue: 0.3513149208, alpha: 1)
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0.5264347196, green: 0.5303700566, blue: 0.6100652218, alpha: 1)
    }
    
}
