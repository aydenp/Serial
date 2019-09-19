//
//  Value.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

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
