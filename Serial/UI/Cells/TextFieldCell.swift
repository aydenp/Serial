//
//  TextFieldCell.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-10.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class TextFieldCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var _textLabel: UILabel!
    
    override var textLabel: UILabel? {
        return _textLabel
    }
}
