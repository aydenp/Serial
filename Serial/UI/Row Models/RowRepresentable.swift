//
//  RowRepresentable.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

protocol RowRepresentable {
    func createCell() -> UITableViewCell
}

protocol SelectableRowRepresentable: RowRepresentable {
    func selectedCell()
}
