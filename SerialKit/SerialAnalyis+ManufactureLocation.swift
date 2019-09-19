//
//  SerialAnalyis+ManufactureLocation.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-05-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

public extension SerialAnalysis {
    enum ManufactureLocation: String {
        case FC = "FC", F = "F", XA = "XA", XB = "XB", QP = "QP", G8 = "G8", RN = "RN", CK = "CK", VM = "VM", SG = "SG", E = "E", MB = "MB", PT = "PT", CY = "CY", EE = "EE", QT = "QT", UV = "UV", FK = "FK", F1 = "F1", F2 = "F2", W8 = "W8", DL = "DL", DM = "DM", DN = "DN", YM = "YM", SevenJ = "7J", OneC = "1C", FourH = "4H", WQ = "WQ", F7 = "F7", C0 = "C0", C3 = "C3", C7 = "C7", C1 = "C1", C2 = "C2", RM = "RM", GH = "GH"
        
        public var locationName: String {
            switch self {
            case .FC: return "Fountain, Colorado, USA"
            case .F: return "Fremont, California, USA"
            case .XA, .XB: return "California, USA"
            case .QP, .G8: return "USA"
            case .RN: return "Mexico"
            case .CK: return "Cork, Ireland"
            case .VM: return "Pardubice, Czech Republic"
            case .SG, .E: return "Singapore"
            case .MB: return "Malaysia"
            case .PT, .CY: return "South Korea"
            case .EE, .QT, .UV: return "Taiwan"
            case .FK, .F1, .F2: return "Zhengzhou, China"
            case .W8, .C7: return "Shanghai, China"
            case .DN: return "Chengdu, China"
            case .C3: return "Shenzhen, China"
            case .DL, .DM, .YM, .SevenJ, .OneC, .FourH, .WQ, .F7, .C0, .C1, .C2: return "China"
            case .RM, .GH: return "Unknown (Refurbished)"
            }
        }
        
        public var factoryOwner: String? {
            switch self {
            case .FC, .F, .CK, .XA, .XB: return "Apple"
            case .VM, .FK, .F1, .F2, .DL, .DM, .DN, .C3: return "Foxconn"
            case .C0, .QT: return "Quanta Computer"
            case .YM, .SevenJ: return "Foxconn (Hon Hai)"
            case .C7: return "Pegatron"
            default: return nil
            }
        }
    }
}
