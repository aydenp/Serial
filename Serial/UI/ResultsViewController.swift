//
//  ResultsViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import SafariServices
import SerialKit

class ResultsViewController: ThemedTableViewController {
    var analysis: SerialAnalysis!
    
    init(analysis: SerialAnalysis) {
        if #available(iOS 13.0, *) {
            super.init(style: .insetGrouped)
        } else {
            super.init(style: .grouped)
        }
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
        var dateRows: [RowRepresentable] = [SubtitleRow(title: analysis.manufactureDate?.description ?? "Unknown", subtitle: analysis.manufactureDate?.dateRangeDescription)]
        if let age = analysis.manufactureDate?.ageDescription { dateRows.append(ValueRow(title: "Age", value: age)) }
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
        let nav = UINavigationController(navigationBarClass: ThemedNavigationBar.self, toolbarClass: nil)
        nav.setViewControllers([vc], animated: false)
        return nav
    }
    
    static func presentAnalysis(for serialNumber: String, onViewController viewController: UIViewController) {
        guard let analysis = SerialAnalysis(serialNumber: serialNumber) else { return }
        viewController.present(getPresentableController(analysis: analysis), animated: true, completion: nil)
    }
    
}

extension SerialAnalysis.ManufactureDate {
    public var dateRangeDescription: String? {
        guard let start = startDate, let end = endDate else { return nil }
        return "\(SerialAnalysis.ManufactureDate.startDateFormatter.string(from: start)) to \(SerialAnalysis.ManufactureDate.endDateFormatter.string(from: end))"
    }
    
    public var ageDescription: String? {
        guard let start = startDate, let age = Calendar.current.dateComponents([.day], from: start, to: Date()).day else { return nil }
        return "\(NumberFormatter.localizedString(from: max(0, age - 7) as NSNumber, number: .decimal))–\(NumberFormatter.localizedString(from: age as NSNumber, number: .decimal)) days"
    }
    
    // MARK: - Formatting
    
    static private let startDateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    static private let endDateFormatter = { () -> DateFormatter in
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d, yyyy"
        return formatter
    }()
}
