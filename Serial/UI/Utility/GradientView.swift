//
//  GradientView.swift
//  Serial
//
//  Created by Ayden Panhuyzen on 2019-09-10.
//  Copyright © 2019 Ayden Panhuyzen. All rights reserved.
//

import UIKit

class GradientView: UIView {
    var gradientLayer: CAGradientLayer {
        return layer as! CAGradientLayer
    }
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    var colours: [UIColor]? {
        get { return gradientLayer.colors?.map { UIColor(cgColor: $0 as! CGColor) } }
        set { gradientLayer.colors = newValue?.map { $0.cgColor } }
    }
}
