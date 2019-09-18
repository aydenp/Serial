//
//  NavigationBar.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-18.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class NavigationBar: UINavigationBar {

    override func didMoveToWindow() {
        super.didMoveToWindow()

        barStyle = .black
        updateStyle()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateStyle()
    }

    private func updateStyle() {
        // Using barStyle = black means UIKit always gives us the dark tint colour dynamically, so we have to do that manually
        if #available(iOS 12.0, *), traitCollection.userInterfaceStyle == .dark {
            barTintColor = nil
        } else {
            barTintColor = UIColor(named: "barTint")
        }
    }
    
}
