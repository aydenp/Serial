//
//  String+LessPainfulSubstring.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

extension String {
    func substring(from start: Int, to end: Int) -> String {
        let startIndex = index(self.startIndex, offsetBy: start), endIndex = index(self.startIndex, offsetBy: end)
        return String(self[startIndex...endIndex])
    }
}
