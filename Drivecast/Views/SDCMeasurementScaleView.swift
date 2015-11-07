//
//  SDCMeasurementScaleView.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

// Gradient line (based on LUT) onto which a mask is applied
class SDCMeasurementScaleGradientView: UIView {
    
    override func drawRect(rect: CGRect) {
        let gradient    = CAGradientLayer()
        let lut         = SDCMeasurementColorLUT()
        let count       = lut.n
        var i           = 0
        
        gradient.colors = (1...count).map { _ in return lut.colorForIndex(lut.n - 1 - i++).CGColor }
        gradient.frame  = CGRectMake(0, 0, frame.width, frame.height)
        
        layer.insertSublayer(gradient, atIndex: 0)
        layer.cornerRadius  = frame.width / 2
        clipsToBounds       = true
    }
}

// Full line used as a background track
class SDCMeasurementScaleBackgroundView: UIView {
    
    override func drawRect(rect: CGRect) {
        layer.cornerRadius  = frame.width / 2
        clipsToBounds       = true
    }
}

// Line used as a mask with lenght based on the CPM value
class SDCMeasurementScaleView: UIView {
    private let lut: SDCMeasurementColorLUT = SDCMeasurementColorLUT()
    
    var cpm: Int = 0 {
        didSet {
            self.progress = CGFloat(lut.indexForValue(cpm)) / CGFloat(lut.n)
        }
    }
    
    private var progress: CGFloat = 0.0 {
        willSet {
            let animation = CABasicAnimation(keyPath: "path")
            
            if let mask = layer.mask as? CAShapeLayer {
                let difference              = (1 - newValue) * bounds.height
                let rect                    = CGRectMake(0, difference, bounds.width, bounds.height * 1.5)
                let path                    = UIBezierPath(roundedRect: rect, cornerRadius: bounds.width / 2).CGPath

                animation.duration          = 0.2
                animation.timingFunction    = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                animation.fromValue         = mask.path
                animation.toValue           = path
                animation.fillMode          = kCAFillModeForwards
                
                mask.path                   = path
                
                mask.addAnimation(animation, forKey: "resizeScaleAnimation")
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let shapeLayer          = CAShapeLayer(layer: layer)
        let difference          = (1 - progress) * bounds.height
        let rect                = CGRectMake(0, difference, bounds.width, bounds.height * 1.5)
        
        shapeLayer.frame        = bounds
        shapeLayer.path         = UIBezierPath(roundedRect: rect, cornerRadius: bounds.width / 2).CGPath
        shapeLayer.fillColor    = UIColor.redColor().CGColor
        
        layer.mask = shapeLayer
        
        layer.cornerRadius      = frame.width / 2
        clipsToBounds           = true
    }
}

