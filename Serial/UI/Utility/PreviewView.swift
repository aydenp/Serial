//
//  PreviewView.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-04-05.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit
import AVFoundation

class PreviewView: UIView {
    var previewLayer: AVCaptureVideoPreviewLayer? {
        didSet {
            oldValue?.removeFromSuperlayer()
            guard let newValue = previewLayer else { return }
            newValue.frame = self.bounds
            layer.addSublayer(newValue)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        previewLayer?.frame = bounds
    }
}
