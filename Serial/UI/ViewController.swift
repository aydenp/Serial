//
//  ViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ViewController: ThemedTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadHistory), name: HistoryManager.notification, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textField?.text = nil
    }
    
    @objc func analyze() {
        guard let text = textField?.text else { return }
        ResultsViewController.presentAnalysis(for: text, onViewController: self)
    }
    
    private weak var textField: UITextField? {
        didSet {
            textField?.addTarget(self, action: #selector(analyze), for: .editingDidEndOnExit)
            textField?.addTarget(self, action: #selector(valueChanged), for: .editingChanged)
        }
    }
    
    private var history = Array(HistoryManager.shared.items.reversed()) {
        didSet { tableView.reloadSections(IndexSet(integer: 1), with: .fade) }
    }
    
    @objc func reloadHistory() {
        history = HistoryManager.shared.items.reversed()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 2
        case 1: return history.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "SerialEntry") as! TextFieldCell
                textField = cell.textField
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "Button") as! ButtonCell
                cell.button.setTitle("Analyze", for: .normal)
                cell.isEnabled = !(textField?.text?.isEmpty ?? true) && SerialAnalysis.isValid(serialNumber: textField!.text!)
                return cell
            default: fatalError("Unknown row.")
            }
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryItem") as! HistoryItemCell
            cell.item = history[indexPath.row]
            return cell
        default: fatalError("Unknown section.")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Manual Entry"
        case 1: return "History"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard section == 1 else { return nil }
        return history.isEmpty ? "No previous analyses." : nil
    }
    
    // MARK: - UITableView Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            if indexPath.row == 1 { analyze() }
        case 1: ResultsViewController.presentAnalysis(for: history[indexPath.row].serialNumber, onViewController: self)
        default: break
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard indexPath.section == 1, editingStyle == .delete else { return }
        HistoryManager.shared.deleteAll(serialNumber: history[indexPath.row].serialNumber)
    }
    
    // MARK: - UITextField actions
    
    @objc func valueChanged() {
        tableView.reloadRows(at: [IndexPath(row: 1, section: 0)], with: .none)
    }
    
}

class TextFieldCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var _textLabel: UILabel!
    
    override var textLabel: UILabel? {
        return _textLabel
    }
}

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
