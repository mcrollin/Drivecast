//
//  SCRMeasurementCircleView.swift
//  safecaster
//
//  Created by Marc Rollin on 10/19/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import AngleGradientLayer

// Circular gradient (based on LUT) onto which a mask is applied
class SDCMeasurementCircleGradientView: UIView {
    let lut: SDCMeasurementColorLUT = SDCMeasurementColorLUT()
    
    override class func layerClass() -> AnyClass {
        return AngleGradientLayer.self
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        let steps       = 64
        let stepSize    = lut.n / steps
        var i           = 0
        let colors      = (1...steps).map { _ in
            return self.lut.colorForIndex(self.lut.n - 1 - stepSize * i++).CGColor
        }
        
        let l: AngleGradientLayer = (self.layer as? AngleGradientLayer)!
        l.colors = colors
    }
}

// Full circle used as a background track
class SDCMeasurementCircleBackgroundView: UIView {
    
    override func drawRect(rect: CGRect) {
        let shapeLayer          = CAShapeLayer(layer: layer)
        shapeLayer.frame        = bounds
        shapeLayer.path         = UIBezierPath(ovalInRect: CGRectMake(12, 12, CGRectGetWidth(frame) - 24, CGRectGetHeight(frame) - 24)).CGPath
        shapeLayer.lineWidth    = 12
        shapeLayer.fillColor    = UIColor.clearColor().CGColor
        shapeLayer.strokeColor  = UIColor.redColor().CGColor
        
        layer.mask = shapeLayer
    }
}

// Partial circle used as a mask on the gradient view
class SDCMeasurementCircleView: UIView {
    private let lut: SDCMeasurementColorLUT = SDCMeasurementColorLUT()
    
    // CPM value based on which we decide how much of the circle to display
    var cpm: Int = 0 {
        didSet {
            let progress = CGFloat(lut.indexForValue(cpm)) / CGFloat(lut.n)
            
            if progress < 0.01 {
                self.progress = 0.01
            } else if progress > 0.99 {
                self.progress = 0.99
            } else {
                self.progress = progress
            }
        }
    }
    
    // Progress indicator of the circle in percent (0.01 to 0.99) based on CPM value
    private var progress: CGFloat = 0.01 {
        willSet {
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            
            if let mask = layer.mask as? CAShapeLayer {
                animation.duration          = 0.3
                animation.timingFunction    = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
                animation.fromValue         = NSNumber(float: Float(mask.strokeEnd))
                animation.toValue           = NSNumber(float: Float(newValue))

                mask.strokeEnd              = newValue
                
                mask.addAnimation(animation, forKey: "drawCircleAnimation")
            }
        }
    }
    
    override func drawRect(rect: CGRect) {
        let circleWidth         = SDCConfiguration.UI.circleWidth
        let shapeLayer          = CAShapeLayer(layer: layer)
        shapeLayer.frame        = bounds
        shapeLayer.lineCap      = kCALineCapRound
        shapeLayer.path         = UIBezierPath(ovalInRect: CGRectMake(circleWidth, circleWidth, CGRectGetWidth(frame) - 2 * circleWidth, CGRectGetHeight(frame) - 2 * circleWidth)).CGPath
        shapeLayer.lineWidth    = circleWidth
        shapeLayer.fillColor    = UIColor.clearColor().CGColor
        shapeLayer.strokeColor  = UIColor.redColor().CGColor
        shapeLayer.strokeStart  = 0.01
        shapeLayer.strokeEnd    = progress
        
        layer.mask = shapeLayer
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        transform = CGAffineTransformMakeRotation(CGFloat(M_PI_2))
    }
}
