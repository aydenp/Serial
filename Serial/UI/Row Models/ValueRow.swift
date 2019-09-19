//
//  ValueRow.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

struct ValueRow: RowRepresentable {
    let title: String, value: Value
    
    init(title: String, value: Value) {
        self.title = title
        self.value = value
    }
    
    init(title: String, value: String?) {
        self.title = title
        self.value = Value(immediate: value)
    }
    
    func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = title
        value.onUpdate = { value in
            cell.detailTextLabel?.text = value ?? "—"
        }
        cell.selectionStyle = .none
        return cell
    }
}
