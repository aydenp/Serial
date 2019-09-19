//
//  AnalyzeIntentHandler.swift
//  Serial Intents
//
//  Created by Ayden Panhuyzen on 2019-09-19.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Intents
import SerialKit

class AnalyzeIntentHandler: NSObject, AnalyzeIntentHandling {

    func handle(intent: AnalyzeIntent, completion: @escaping (AnalyzeIntentResponse) -> Void) {
        guard let serialNumber = intent.serialNumber, let analysis = SerialAnalysis(serialNumber: serialNumber) else {
            completion(AnalyzeIntentResponse(code: .failure, userActivity: nil))
            return
        }
        func checkIfComplete() {
            guard analysis.isComplete else { return }
            completion(AnalyzeIntentResponse.success(analysis: analysis.intentResults))
        }
        analysis.register { _ in checkIfComplete() }
        checkIfComplete()
    }
    
    func resolveSerialNumber(for intent: AnalyzeIntent, with completion: @escaping (AnalyzeSerialNumberResolutionResult) -> Void) {
        guard let serialNumber = intent.serialNumber else {
            completion(.needsValue())
            return
        }
        guard SerialAnalysis.isValid(serialNumber: serialNumber) else {
            completion(.unsupported(forReason: .invalid))
            return
        }
        completion(.success(with: serialNumber))
    }
    
}

extension SerialAnalysis {
    var intentResults: AnalysisResults {
        let results = AnalysisResults(identifier: nil, display: deviceName ?? "Unknown Device")
        results.serialNumber = serialNumber
        results.deviceName = deviceName
        results.manufactureDate = manufactureDate?.intentResults
        results.manufactureLocation = manufactureLocation?.locationName
        results.osFamily = osFamily?.friendlyName
        results.probableVersion = probableVersion
        return results
    }
}

extension SerialAnalysis.ManufactureDate {
    var intentResults: ManufactureDateRangeResults {
        let results = ManufactureDateRangeResults(identifier: nil, display: description)
        results.startDate = startDate.map { Calendar.current.dateComponents([.day, .month, .year], from: $0) }
        results.endDate = endDate.map { Calendar.current.dateComponents([.day, .month, .year], from: $0) }
        return results
    }
}
