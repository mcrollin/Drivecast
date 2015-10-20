//
//  SDCUploadViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SnapKit

import RealmSwift

class SDCUploadViewController: UIViewController {
    let viewModel   = SDCUploadViewModel()

    var mapView: MKMapView?
    var dimOverlay: MKPolygon? {
        willSet(overlay) {
            if let overlay = overlay {
                mapView?.addOverlay(overlay)
            } else {
                mapView?.removeOverlay(dimOverlay!)
            }
        }
    }
    
    var multiMeasurementOverlay: SDCMultiMeasurementOverlay? {
        willSet(overlay) {
            if let overlay = overlay {
                mapView?.addOverlay(overlay)
            } else {
                if let multiMeasurementOverlay = multiMeasurementOverlay {
                    mapView?.removeOverlay(multiMeasurementOverlay)
                }
            }
        } didSet {
            centerMap(false)
        }
    }
    
    @IBOutlet var centerMapButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var discardButton: UIButton!
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var measurementScaleView: SDCMeasurementScaleView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMap()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        viewModel.updateMeasurements()
        
        let realm                       = try! Realm()
        let measurements                = realm.objects(SDCMeasurement).sorted("date")
        let measurementsWithLocation    = measurements.filter("dataValidity = true && gpsValidity = true")
        let lut                         = SDCMeasurementColorLUT()
        
        if measurementsWithLocation.count > 0 {
            let overlays = measurementsWithLocation
                .map { measurement -> SDCMeasurementOverlay in
                    let overlay     = SDCMeasurementOverlay(centerCoordinate: measurement.location2D, radius: 2)
                    overlay.color   = lut.colorForValue(measurement.cpm)
                    
                    return overlay
            }
            
            multiMeasurementOverlay = SDCMultiMeasurementOverlay(measurements: overlays)
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        unloadMap()
    }
}

// MARK - UIView
extension SDCUploadViewController {
    
    func configureView() {
        view.backgroundColor            = UIColor(named: .Background)
        discardButton.backgroundColor   = UIColor(named: .Alert)
        uploadButton.backgroundColor    = UIColor(named: .Main)
        discardButton.isRounded         = true
        uploadButton.isRounded          = true
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
    }
    
    func openAboutModal() {
        let about = UIStoryboard.Scene.Main.aboutViewController()
    
        self.presentViewController(about, animated: true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCUploadViewController {
    
    func bindViewModel() {
        centerMapButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside).subscribeNext { _ in
            self.centerMap(true)
        }
    }
}

// MARK - Map

extension SDCUploadViewController {
    private func loadMap() {
        mapView = MKMapView()
        
        mapView!.pitchEnabled   = false
        mapView!.delegate       = self
        
        mapContainerView.insertSubview(mapView!, atIndex: 0)

        mapView!.snp_makeConstraints { make in
            make.edges.equalTo(mapContainerView)
        }
        
        var points = [MKMapPoint(x: MKMapRectWorld.origin.x, y: MKMapRectWorld.origin.y),
            MKMapPoint(x: MKMapRectWorld.origin.x + MKMapRectWorld.size.width, y: MKMapRectWorld.origin.y),
            MKMapPoint(x: MKMapRectWorld.origin.x + MKMapRectWorld.size.width, y: MKMapRectWorld.origin.y + MKMapRectWorld.size.height),
            MKMapPoint(x: MKMapRectWorld.origin.x, y: MKMapRectWorld.origin.y + MKMapRectWorld.size.height)]
        
        dimOverlay      = MKPolygon(points: &points, count: points.count)
        mapView!.alpha  = 0
        
        UIView.animateWithDuration(1.0, delay:0.5, options: .TransitionCrossDissolve, animations: {
            self.mapView!.alpha = 1
            }, completion: nil)
    }
    
    private func unloadMap() {
        multiMeasurementOverlay = nil
        dimOverlay              = nil
        
        mapView?.mapType        = .Hybrid
        
        mapView?.removeFromSuperview()
        
        mapView?.delegate       = nil
        mapView                 = nil
    }
    
    private func centerMap(animated: Bool) {
        if animated {
            measurementScaleView.cpm    = Int(arc4random_uniform(500))
        }
        
        if let multiMeasurementOverlay = multiMeasurementOverlay {
            let boundingMapRect = multiMeasurementOverlay.boundingMapRect
            let visibleRect = MKMapRectMake(boundingMapRect.origin.x - boundingMapRect.size.width * 0.2,
                boundingMapRect.origin.y - boundingMapRect.size.height * 0.2,
                boundingMapRect.size.width * 1.4,
                boundingMapRect.size.height * 1.4)
            
            mapView?.setVisibleMapRect(visibleRect, animated: animated)
        }
    }
}

// MARK - MKMapViewDelegate
extension SDCUploadViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKindOfClass(MKPolygon) {
            let color = UIColor(named: .Background)
            let overlayRenderer: MKPolygonRenderer = MKPolygonRenderer(overlay: overlay)
            
            overlayRenderer.alpha = 0.75
            overlayRenderer.fillColor = color
            
            return overlayRenderer
            
        } else {
            let overlayRenderer: SCRMultiMeasurementOverlayRenderer = SCRMultiMeasurementOverlayRenderer(overlay: overlay)
            
            return overlayRenderer
        }
    }
}
