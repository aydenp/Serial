//
//  Section.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

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
