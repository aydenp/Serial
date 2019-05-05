//
//  ResultsHeaderView.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class ResultsHeaderView: UIView {
    var analysis: SerialAnalysis!
    private var titleLabel = UILabel(), numberLabel = UILabel()
    
    init(analysis: SerialAnalysis) {
        super.init(frame: .zero)
        self.analysis = analysis
        
        titleLabel.font = .systemFont(ofSize: 26, weight: .medium)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.6
        titleLabel.textColor = .white
        
        numberLabel.font = .systemFont(ofSize: 15)
        numberLabel.textColor = .lightGray
        
        self.analysis.register { self.update(with: $0) }
        self.update(with: analysis)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, numberLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 4
        addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: topAnchor, constant: 40).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12).isActive = true
        stackView.leftAnchor.constraint(equalTo: leftAnchor, constant: 20).isActive = true
        stackView.rightAnchor.constraint(equalTo: rightAnchor, constant: -20).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(with analysis: SerialAnalysis) {
        titleLabel.text = analysis.deviceName ?? "Unknown"
        numberLabel.text = analysis.serialNumber
    }
}
