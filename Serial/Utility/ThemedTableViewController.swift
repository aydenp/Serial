//
//  ThemedTableViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-07.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ThemedTableViewController: UITableViewController {

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.textLabel?.textColor = .white
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0.5264347196, green: 0.5303700566, blue: 0.6100652218, alpha: 1)
    }
    
}
