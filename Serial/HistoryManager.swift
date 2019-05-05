//
//  RecentAnalysesManager.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class HistoryManager {
    private static let defaultsKey = "history"
    static let shared = HistoryManager()
    static let notification = Notification.Name(rawValue: "SerialHistoryManagerItemsChangedNotificationName")
    
    private init() {}
    
    func record(serialNumber: String) {
        deleteAll(serialNumber: serialNumber)
        items.append(Item(serialNumber: serialNumber, date: Date()))
    }
    
    func deleteAll(serialNumber: String) {
        items.removeAll { $0.serialNumber == serialNumber }
    }
    
    private var _items: [Item]?
    var items: [Item] {
        get {
            if _items == nil {
                _items = UserDefaults.standard.array(forKey: HistoryManager.defaultsKey)?.filter { $0 is Data }.compactMap { try? JSONDecoder().decode(Item.self, from: $0 as! Data) }
            }
            return _items ?? []
        }
        set {
            _items = Array(newValue.suffix(10))
            NotificationCenter.default.post(name: HistoryManager.notification, object: nil)
            UserDefaults.standard.set(_items!.compactMap { try? JSONEncoder().encode($0) }, forKey: HistoryManager.defaultsKey)
        }
    }
    
    struct Item: Codable {
        let serialNumber: String, date: Date
    }
}
