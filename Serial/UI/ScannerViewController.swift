//
//  ScannerViewController.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-04.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

class ScannerViewController: UIViewController {
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var torchItem: UIBarButtonItem!
    @IBOutlet weak var permissionView: UIView!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var loadingIcon: UIActivityIndicatorView!
    
    private var isFinished = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup legibility gradient view
        gradientView.colours = [.clear, UIColor(white: 0, alpha: 0.8)]
        gradientView.gradientLayer.startPoint = .zero
        gradientView.gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        
        setup()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isTorchEnabled = false
    }
    
    func scan(serialNumber: String) {
        if isFinished { return }
        isFinished = true
        let presenting = self.navigationController!.presentingViewController!
        DispatchQueue.main.async {
            self.destroyCam()
            self.dismiss(animated: false) { ResultsViewController.presentAnalysis(for: serialNumber, onViewController: presenting) }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        adjustOrientation()
    }
    
    func adjustOrientation() {
        guard let connection = self.previewView?.previewLayer?.connection, connection.isVideoOrientationSupported else { return }
        switch UIDevice.current.orientation {
            case .landscapeRight: connection.videoOrientation = .landscapeLeft
            case .landscapeLeft: connection.videoOrientation = .landscapeRight
            case .portraitUpsideDown: connection.videoOrientation = .portraitUpsideDown
            default: connection.videoOrientation = .portrait
        }
    }
    
    enum Mode {
        case needsPermission, loading, scanning
    }
    
    var device: AVCaptureDevice? {
        didSet { updateTorchItem() }
    }
    
    var isTorchEnabled: Bool {
        get {
            return device?.torchMode ?? .off == .on
        }
        set {
            guard let device = device, isTorchEnabled != newValue else { return }
            do {
                try device.lockForConfiguration()
                device.torchMode = newValue ? .on : .off
                device.unlockForConfiguration()
                updateTorchItem()
            } catch let error {
                self.showErrorAlert(title: "Couldn't Toggle Light", error: error, unknownMessage: "An error occurred while attempting to toggle the flashlight.")
            }
        }
    }
    
    @IBAction func torchTapped(_ sender: Any) {
        isTorchEnabled.toggle()
    }
    
    private func updateTorchItem() {
        torchItem.isEnabled = device?.isTorchAvailable ?? false
        torchItem.image = UIImage(named: isTorchEnabled ? "Torch_On" : "Torch_Off")
        torchItem.accessibilityLabel = "Toggle Flashlight"
        torchItem.accessibilityValue = isTorchEnabled ? "Turn flashlight off" : "Turn flashlight on"
    }
    
    var mode = Mode.loading {
        didSet {
            let mode = self.mode
            OperationQueue.main.addOperation {
                self.loadingIcon.isHidden = mode != .loading
                self.permissionView.isHidden = mode != .needsPermission
                self.hintLabel.isHidden = mode != .scanning
                self.gradientView.isHidden = mode != .scanning
            }
        }
    }
    
    func setup() {
        mode = .loading
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.mode = .scanning
                self.setupCam()
            } else {
                self.mode = .needsPermission
                self.destroyCam()
            }
        }
    }
    
    var session: AVCaptureSession? {
        didSet { oldValue?.stopRunning() }
    }
    
    func destroyCam() {
        OperationQueue.main.addOperation { self.previewView?.previewLayer = nil }
        isTorchEnabled = false
        session = nil
        device = nil
    }
    
    func setupCam() {
        // Allow providing fake demo camera input (for use in simulator)
        if let demoImage = UIImage(named: "DemoFakeCamera") {
            OperationQueue.main.addOperation {
                let imageView = UIImageView(image: demoImage)
                imageView.frame = self.previewView.bounds
                imageView.contentMode = .scaleAspectFill
                imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                self.previewView.addSubview(imageView)
            }
            
            self.mode = .scanning
            return
        }
        
        func fail(with error: Error? = nil) {
            self.destroyCam()
            self.showErrorAlert(title: "Camera Error", error: error, unknownMessage: "There was an error trying to access your device's camera.", action: .ok { _ in self.dismiss(animated: true, completion: nil)}, completion: nil)
        }
        
        self.destroyCam()
        do {
            let session = AVCaptureSession()
            guard let device = AVCaptureDevice.default(for: .video) else { fail(); return }
            
            let input = try AVCaptureDeviceInput(device: device)
            session.addInput(input)
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.global())
            session.addOutput(output)
            guard output.availableMetadataObjectTypes.contains(.code128) else { fail(); return }
            output.metadataObjectTypes = [.code128]
        
            let layer = AVCaptureVideoPreviewLayer(session: session)
            layer.videoGravity = .resizeAspectFill
            OperationQueue.main.addOperation {
                self.adjustOrientation()
                self.previewView.previewLayer = layer
            }
            
            session.startRunning()
            self.mode = .scanning
            
            self.device = device
            self.session = session
        } catch let error {
            fail(with: error)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let device = self.device else { return }
        
        for touch in touches {
            let originalPoint = touch.location(in: touch.view)
            let screenRect = UIScreen.main.bounds
            let point = CGPoint(x: originalPoint.x / screenRect.size.width, y: originalPoint.y / screenRect.size.height)
            do {
                if device.isFocusPointOfInterestSupported {
                    try device.lockForConfiguration()
                    device.focusPointOfInterest = point
                    device.exposurePointOfInterest = point
                    device.focusMode = device.isFocusModeSupported(.continuousAutoFocus) ? .continuousAutoFocus : .autoFocus
                    device.exposureMode = device.isExposureModeSupported(.continuousAutoExposure) ? .continuousAutoExposure : .autoExpose
                    device.unlockForConfiguration()
                }
            } catch _ {}
        }
    }
    
    @IBAction func openSettingsPressed(_ sender: Any) {
        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
    }
    
    @IBAction func dismissTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}

extension ScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let text = ((metadataObjects.first {
            guard let barcode = $0 as? AVMetadataMachineReadableCodeObject, let text = barcode.stringValue else { return false }
            return text.count == 13 && text.hasPrefix("S")
        }) as? AVMetadataMachineReadableCodeObject)?.stringValue?.dropFirst() else { return }
        scan(serialNumber: String(text))
    }
}
