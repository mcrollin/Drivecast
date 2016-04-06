//
//  SCRMultiMeasurementOverlayRenderer.swift
//  safecaster
//
//  Created by Marc Rollin on 5/13/15.
//  Copyright (c) 2015 safecast. All rights reserved.
//

import UIKit
import MapKit

class SCRMultiMeasurementOverlayRenderer: MKOverlayRenderer {

    private func drawMeasurement(overlay: SDCMeasurementOverlay, rectForMapRect: CGRect, zoomScale: CGFloat, inContext context: CGContext) {
        let radius      = overlay.radius / Double(zoomScale)
        let center      = self.pointForMapPoint(MKMapPointForCoordinate(overlay.coordinate))
        let innerRadius = CGFloat(MKMapPointsPerMeterAtLatitude(overlay.coordinate.latitude) * radius)
        let outerRadius = CGFloat(MKMapPointsPerMeterAtLatitude(overlay.coordinate.latitude) * (radius + 2))
        let innerRect   = CGRectMake(center.x - innerRadius, center.y - innerRadius, innerRadius * 2.0, innerRadius * 2.0)
        let outerRect   = CGRectMake(center.x - outerRadius, center.y - outerRadius, outerRadius * 2.0, outerRadius * 2.0)
        
        if CGRectIntersectsRect(rectForMapRect, outerRect) {
            CGContextAddRect(context, rectForMapRect)
            
            CGContextSaveGState(context)
            
            CGContextSetLineWidth(context, 2)
            CGContextSetStrokeColorWithColor(context, UIColor.whiteColor().CGColor)
            CGContextSetFillColorWithColor(context, overlay.color.CGColor)
            
            CGContextBeginPath(context)
            CGContextAddEllipseInRect(context, innerRect)
            CGContextDrawPath(context, CGPathDrawingMode.FillStroke)
            
            CGContextRestoreGState(context)
            
            UIGraphicsPopContext()
        }
    }
    
    override func drawMapRect(mapRect: MKMapRect, zoomScale: MKZoomScale, inContext context: CGContext) {
        let multiMeasurements       = overlay as! SDCMultiMeasurementOverlay
        let rectForMapRect          = self.rectForMapRect(mapRect)
        let measurements            = multiMeasurements.measurements
        let scale                   = 1 / zoomScale
        let frequency               = Int(log(scale) + 1)
        var measurementsCount       = 0
        
        for measurement in measurements {
            if frequency < 1 || measurementsCount % frequency == 0 {
                drawMeasurement(measurement,
                    rectForMapRect: rectForMapRect,
                    zoomScale: zoomScale,
                    inContext: context)
            }
            
            measurementsCount   += 1
        }
    }
}