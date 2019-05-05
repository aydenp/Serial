//
//  SerialAnalysis.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import Foundation

class SerialAnalysis {
    typealias UpdateBlock = (SerialAnalysis) -> ()
    private var _observers = [UpdateBlock]()
    let serialNumber: String
    let manufactureLocation: ManufactureLocation?, manufactureDate: ManufactureDate?, techSpecsURL: URL?, checkCoverageURL: URL?, modelPart: String
    
    private var probableVersionTask: URLSessionDataTask?
    
    var deviceName: String? {
        didSet {
            osFamily = deviceName != nil ? OSFamily.from(deviceName: deviceName!) : nil
            postUpdateNotification()
        }
    }
    
    var osFamily: OSFamily? {
        didSet {
            guard oldValue != osFamily else { return }
            fetchProbableVersion()
        }
    }
    
    var probableVersion: String? {
        didSet { postUpdateNotification() }
    }
    
    init?(serialNumber: String) {
        self.serialNumber = serialNumber.uppercased()
        guard SerialAnalysis.isValid(serialNumber: self.serialNumber) else { return nil }
        manufactureLocation = ManufactureLocation(rawValue: String(self.serialNumber.prefix(2)))
        manufactureDate = ManufactureDate(serialNumberPart: self.serialNumber.substring(from: 3, to: 4))
        modelPart = self.serialNumber.substring(from: 8, to: 11)
        techSpecsURL = URL(string: "https://support-sp.apple.com/sp/index?page=cpuspec&cc=\(modelPart)")
        checkCoverageURL = URL(string: "https://checkcoverage.apple.com/?sn=\(self.serialNumber)")
        fetchDeviceName()
    }
    
    private func postUpdateNotification() {
        DispatchQueue.main.async {
            self._observers.forEach { $0(self) }
        }
    }
    
    static func isValid(serialNumber: String) -> Bool {
        return serialNumber.count == 12
    }
    
    private func fetchDeviceName() {
        deviceName = nil
        guard let url = URL(string: "https://support-sp.apple.com/sp/product?cc=\(modelPart)") else { return }
        var request = URLRequest(url: url)
        request.addValue("application/xhtml+xml,application/xml", forHTTPHeaderField: "Accept")
        request.cachePolicy = .returnCacheDataElseLoad
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data, let xmlString = String(data: data, encoding: .utf8) else { print("Fetch device name error:", error ?? "none"); return }
            // im so disappointed in myself :(
            guard let startIndex = xmlString.range(of: "<configCode>")?.upperBound, let endIndex = xmlString.range(of: "</configCode>", options: .init(rawValue: 0), range: startIndex..<xmlString.endIndex, locale: nil)?.lowerBound else { return }
            // seriously wyd
            self.deviceName = String(xmlString[startIndex..<endIndex])
        }.resume()
    }
    
    private func fetchProbableVersion() {
        probableVersion = nil
        probableVersionTask?.cancel()
        guard let platform = osFamily?.rawValue, let weekEnd = manufactureDate?.endDate?.timeIntervalSince1970, let url = URL(string: "https://deviceinfo.madebyayden.co/\(platform)/\(Int(weekEnd))") else { return }
        probableVersionTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil, let data = data, let string = String(data: data, encoding: .utf8) else { print("Fetch latest version error:", error ?? "none"); return }
            self.probableVersion = string
            self.probableVersionTask = nil
        }
        probableVersionTask!.resume()
    }
    
    // MARK: - Registration
    
    func register(observer: @escaping UpdateBlock) {
        _observers.append(observer)
        DispatchQueue.main.async {
            observer(self)
        }
    }
}
