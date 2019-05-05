//
//  ResultsViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import SafariServices

class ResultsViewController: ThemedTableViewController {
    var analysis: SerialAnalysis!
    
    init(analysis: SerialAnalysis) {
        super.init(style: .grouped)
        self.analysis = analysis
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Analysis"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissResults))
        HistoryManager.shared.record(serialNumber: analysis.serialNumber)
        tableView.tableHeaderView = ResultsHeaderView(analysis: analysis)

        var sections = [Section]()
    
        // Location info
        var locationRows = [ValueRow(title: "Location", value: analysis.manufactureLocation?.locationName ?? "Unknown")]
        if let owner = analysis.manufactureLocation?.factoryOwner { locationRows.append(ValueRow(title: "Owner", value: owner)) }
        sections.append(Section(rows: locationRows, header: "Factory"))
        
        // Date info:
        var dateRows: [RowRepresentable] = [SubtitleRow(title: analysis.manufactureDate?.description ?? "Unknown", subtitle: analysis.manufactureDate?.dateRangeText)]
        if let age = analysis.manufactureDate?.ageText { dateRows.append(ValueRow(title: "Age", value: age)) }
        sections.append(Section(rows: dateRows, header: "Manufacture Date"))
        
        sections.append(Section(rows: [ValueRow(title: "Family", value: .async { (update) in
            analysis.register { update($0.osFamily?.friendlyName) }
        }), ValueRow(title: "Probable Version", value: .async { (update) in
            analysis.register { update($0.probableVersion) }
        })], header: "Operating System", footer: "The latest software version at the end of the week of manufacture."))
        
        sections.append(Section(rows: [ActionRow(title: "Open Tech Specs", url: analysis.techSpecsURL, viewController: self), ActionRow(title: "Check Coverage", url: analysis.checkCoverageURL, viewController: self)], header: "More Information", footer: nil))
        
        self.sections = sections
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let headerView = tableView.tableHeaderView {
            let height = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
            var headerFrame = headerView.frame

            if height != headerFrame.size.height {
                headerFrame.size.height = height
                headerView.frame = headerFrame
                tableView.tableHeaderView = headerView
            }
        }
    }
    
    var sections: [Section] = [] {
        didSet { tableView.reloadData() }
    }
    
    @objc func dismissResults() {
        dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sections[indexPath.section].rows[indexPath.row].createCell()
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].header
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sections[section].footer
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowItem = sections[indexPath.section].rows[indexPath.row] as? SelectableRowRepresentable else { return }
        rowItem.selectedCell()
    }
    
    // MARK: - Convenience
    
    static func getPresentableController(analysis: SerialAnalysis) -> UIViewController {
        let vc = ResultsViewController(analysis: analysis)
        return UINavigationController(rootViewController: vc)
    }
    
    static func presentAnalysis(for serialNumber: String, onViewController viewController: UIViewController) {
        guard let analysis = SerialAnalysis(serialNumber: serialNumber) else { return }
        viewController.present(getPresentableController(analysis: analysis), animated: true, completion: nil)
    }
    
}

struct Section {
    let header: String?, footer: String?
    let rows: [RowRepresentable]
    
    init(rows: [RowRepresentable], header: String? = nil, footer: String? = nil) {
        self.rows = rows
        self.header = header
        self.footer = footer
    }
    
    init(row: RowRepresentable, header: String? = nil, footer: String? = nil) {
        self.init(rows: [row], header: header, footer: footer)
    }
}

protocol RowRepresentable {
    func createCell() -> UITableViewCell
}

protocol SelectableRowRepresentable: RowRepresentable {
    func selectedCell()
}

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

struct SubtitleRow: RowRepresentable {
    let title: String, subtitle: String?
    
    func createCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        cell.selectionStyle = .none
        return cell
    }
}


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

class Value {
    init(immediate value: String?) {
        self.value = value
    }
    
    init(block: AsyncValueProviderBlock) {
        block({ [weak self] in
            self?.value = $0
        })
    }
    
    var onUpdate: UpdateBlock? {
        didSet { fireUpdateHandler() }
    }
    
    private var value: String? {
        didSet { fireUpdateHandler() }
    }
    
    private func fireUpdateHandler() {
        DispatchQueue.main.async {
            self.onUpdate?(self.value)
        }
    }
    
    static func async(_ block: AsyncValueProviderBlock) -> Value {
        return Value(block: block)
    }
    
    typealias UpdateBlock = (String?) -> ()
    typealias AsyncValueProviderBlock = (_ update: @escaping UpdateBlock) -> ()
}
