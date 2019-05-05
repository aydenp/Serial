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
    /// Contains blocks to notify when new data is received
    private var _observers = [UpdateBlock]()
    /// The full serial number being analyzed.
    let serialNumber: String
    /// The last digits of the serial number which identify this device's model (Space Grey iPhone X, etc)
    let modelPart: String
    let manufactureLocation: ManufactureLocation?, manufactureDate: ManufactureDate?, techSpecsURL: URL?, checkCoverageURL: URL?
    
    private var probableVersionTask: URLSessionDataTask?
    
    /// The device's friendly name, such as 'iPhone X' or 'Apple Watch Series 4 Stainless Steel 44mm Silver'
    var deviceName: String? {
        didSet {
            // Set the probable OS name based on the device's friendly name
            osFamily = deviceName != nil ? OSFamily.from(deviceName: deviceName!) : nil
            postUpdateNotification()
        }
    }
    
    /// The most likely OS family this device belongs to, based on the device's friendly name
    var osFamily: OSFamily? {
        didSet {
            guard oldValue != osFamily else { return }
            fetchProbableVersion()
        }
    }
    
    /// The highest version this device can ship on, if available.
    var probableVersion: String? {
        didSet { postUpdateNotification() }
    }
    
    init?(serialNumber: String) {
        self.serialNumber = serialNumber.uppercased()
        // Ensure serial number is valid
        guard SerialAnalysis.isValid(serialNumber: self.serialNumber) else { return nil }
        // Parse available information from number and leave other info for later
        manufactureLocation = ManufactureLocation(rawValue: String(self.serialNumber.prefix(2)))
        manufactureDate = ManufactureDate(serialNumberPart: self.serialNumber.substring(from: 3, to: 4))
        modelPart = self.serialNumber.substring(from: 8, to: 11)
        // Set Apple Support URLs
        techSpecsURL = URL(string: "https://support-sp.apple.com/sp/index?page=cpuspec&cc=\(modelPart)")
        checkCoverageURL = URL(string: "https://checkcoverage.apple.com/?sn=\(self.serialNumber)")
        fetchDeviceName()
    }
    
    /// Notifies our observers that a data change has occurred.
    private func postUpdateNotification() {
        DispatchQueue.main.async {
            self._observers.forEach { $0(self) }
        }
    }
    
    static func isValid(serialNumber: String) -> Bool {
        // TODO: There's a lot more to check to make sure it's valid.
        return serialNumber.count == 12
    }
    
    /// Fetches the device name from Apple's Support API given the last few digits of the serial number
    private func fetchDeviceName() {
        deviceName = nil
        guard let url = URL(string: "https://support-sp.apple.com/sp/product?cc=\(modelPart)") else { return }
        var request = URLRequest(url: url)
        request.addValue("application/xhtml+xml,application/xml", forHTTPHeaderField: "Accept")
        request.cachePolicy = .returnCacheDataElseLoad
        // Make the request
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            guard error == nil, let data = data, let xmlString = String(data: data, encoding: .utf8) else { print("Fetch device name error:", error ?? "none"); return }
            // Who needs an XML parser, right??
            // im so disappointed in myself :(
            guard let startIndex = xmlString.range(of: "<configCode>")?.upperBound, let endIndex = xmlString.range(of: "</configCode>", options: .init(rawValue: 0), range: startIndex..<xmlString.endIndex, locale: nil)?.lowerBound else { return }
            // seriously wyd
            self.deviceName = String(xmlString[startIndex..<endIndex])
        }.resume()
    }
    
    /// Fetches the probable device version from the data server
    private func fetchProbableVersion() {
        probableVersion = nil
        // Cancel any currently running tasks to find the version
        probableVersionTask?.cancel()
        // Construct the URL (this is kinda hard to read)
        guard let platform = osFamily?.rawValue, let weekEnd = manufactureDate?.endDate?.timeIntervalSince1970, let url = URL(string: "https://deviceinfo.madebyayden.co/\(platform)/\(Int(weekEnd))") else { return }
        // Fetch the version!
        probableVersionTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
            // The response is just the version in plain text, so just decode it to a string
            guard error == nil, let data = data, let string = String(data: data, encoding: .utf8) else { print("Fetch latest version error:", error ?? "none"); return }
            self.probableVersion = string
            self.probableVersionTask = nil
        }
        probableVersionTask!.resume()
    }
    
    // MARK: - Registration
    
    /**
      Register an observer to receive future data update notifications about this analysis.
      It will be called immediately to allow populating the data more conveniently.
    */
    func register(observer: @escaping UpdateBlock) {
        _observers.append(observer)
        // Call the observer for convenience
        DispatchQueue.main.async {
            observer(self)
        }
    }
}
