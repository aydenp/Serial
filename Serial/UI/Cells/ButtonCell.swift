//
//  ButtonCell.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-10.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ButtonCell: UITableViewCell {
    @IBOutlet weak var button: UIButton!
    
    var isEnabled: Bool {
        get {
            return button.isEnabled
        }
        set {
            button.isEnabled = newValue
            selectionStyle = newValue ? .default : .none
        }
    }
}
