//
//  ActionRow.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import SafariServices

struct ActionRow: SelectableRowRepresentable {
    let title: String, action: () -> ()
    
    init(title: String, action: @escaping () -> ()) {
        self.title = title
        self.action = action
    }
    
    init(title: String, url: URL?, viewController: UIViewController) {
        self.title = title
        self.action = {
            guard let url = url else { return }
            let svc = SFSafariViewController(url: url)
            viewController.present(svc, animated: true, completion: nil)
        }
    }
    
    func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.selectionStyle = .default
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func selectedCell() {
        action()
    }
}
