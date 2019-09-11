//
//  HistoryItemCell.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-10.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class HistoryItemCell: UITableViewCell {
    @IBOutlet weak var serialNumberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    private var hasAwaken = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        populateData()
        hasAwaken = true
    }
    
    var item: HistoryManager.Item? {
        didSet {
            guard hasAwaken else { return }
            populateData()
        }
    }
    
    private func populateData() {
        serialNumberLabel.text = item?.serialNumber
        dateLabel.text = item != nil ? DateFormatter.localizedString(from: item!.date, dateStyle: .short, timeStyle: .short) : nil
    }
}
