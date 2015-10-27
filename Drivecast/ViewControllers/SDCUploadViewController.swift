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
import BEMSimpleLineGraph

class SDCUploadViewController: UIViewController {
    
    // ViewModel handling all logic
    let viewModel   = SDCUploadViewModel()
    
    // Map only loaded when screen is visible
    var mapView: MKMapView?
    
    // Dimmed overlay
    var dimOverlay: MKPolygon? {
        willSet(overlay) {
            if let overlay = overlay {
                mapView?.addOverlay(overlay)
            } else {
                mapView?.removeOverlay(dimOverlay!)
            }
        }
    }
    
    // Measurements overlay
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
    
    // Actions
    var discardCocoaAction: CocoaAction!
    var uploadCocoaAction: CocoaAction!
    
    // IB variables
    @IBOutlet var uploadView: UIView!
    @IBOutlet var centerMapButton: UIButton!
    @IBOutlet var uploadButton: UIButton!
    @IBOutlet var discardButton: UIButton!
    @IBOutlet var mapContainerView: UIView!
    @IBOutlet var measurementScaleView: SDCMeasurementScaleView!
    @IBOutlet var measurementLineGraphView: BEMSimpleLineGraphView!
    @IBOutlet var valuesContainerView: UIView!
    @IBOutlet var selectionView: UIView!
    @IBOutlet var cpmValueLabel: UILabel!
    @IBOutlet var cpmUnitLabel: UILabel!
    @IBOutlet var usvhValueLabel: UILabel!
    @IBOutlet var usvhUnitLabel: UILabel!
    @IBOutlet var actionLabel: UILabel!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var noMeasurementLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMap()
        viewModel.updateMeasurementData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidAppear(animated)
        
        unloadMap()
    }
}

// MARK - UIView
extension SDCUploadViewController {
    
    func configureView() {
        let separatorLineColor              = UIColor(named: .Separator)
        let mainColor                       = UIColor(named: .Main)
        let backgroundColor                 = UIColor(named: .Background)
        view.backgroundColor                = backgroundColor
        mapContainerView.backgroundColor    = backgroundColor
        
        // About Button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
        
        // Action Buttons
        discardButton.backgroundColor       = UIColor(named: .Alert)
        uploadButton.backgroundColor        = mainColor
        recordButton.backgroundColor        = mainColor
        discardButton.isRounded             = true
        uploadButton.isRounded              = true
        recordButton.isRounded              = true
        noMeasurementLabel.textColor        = UIColor(named: .Text)
        
        // Map related button
        centerMapButton.isRounded           = true
        centerMapButton.layer.borderColor   = separatorLineColor.CGColor
        centerMapButton.layer.borderWidth   = 1
        
        // Line Graph
        measurementLineGraphView.animationGraphStyle    = BEMLineAnimation.None
        measurementLineGraphView.enableBezierCurve      = true
        measurementLineGraphView.enableXAxisLabel       = false
        measurementLineGraphView.autoScaleYAxis         = true
        measurementLineGraphView.enableTouchReport      = true
        measurementLineGraphView.colorTouchInputLine    = mainColor
        measurementLineGraphView.colorLine              = mainColor
        measurementLineGraphView.colorPoint             = mainColor.colorWithAlphaComponent(0.8)
        measurementLineGraphView.colorTop               = UIColor.whiteColor().colorWithAlphaComponent(0.7)
        measurementLineGraphView.colorBottom            = UIColor.clearColor()
        measurementLineGraphView.backgroundColor        = backgroundColor
        measurementLineGraphView.layer.borderColor      = separatorLineColor.CGColor
        measurementLineGraphView.layer.borderWidth      = 1
        
        // Selection
        selectionView.isRounded             = true
        selectionView.backgroundColor       = UIColor.clearColor()
        selectionView.layer.borderColor     = separatorLineColor.CGColor
        selectionView.layer.borderWidth     = 1
        
        // Value Container
        valuesContainerView.layer.cornerRadius  = 5
        valuesContainerView.layer.borderWidth   = 1
        valuesContainerView.layer.borderColor   = separatorLineColor.CGColor
        valuesContainerView.clipsToBounds       = true
        valuesContainerView.backgroundColor     = UIColor.whiteColor().colorWithAlphaComponent(0.8)
        
        // Values
        cpmValueLabel.textColor     = UIColor(named: .Text)
        cpmUnitLabel.textColor      = UIColor(named: .LightText)
        usvhValueLabel.textColor    = UIColor(named: .Text)
        usvhUnitLabel.textColor     = UIColor(named: .LightText)
    }
    
    func openAboutModal() {
        let about = UIStoryboard.Scene.Main.aboutViewController()
        
        self.presentViewController(about, animated: true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCUploadViewController {
    
    func bindViewModel() {
        usvhValueLabel.rac_text <~ viewModel.usvhValueString
        cpmValueLabel.rac_text  <~ viewModel.cpmValueString
        actionLabel.rac_text    <~ viewModel.actionString
        
        uploadButtonEvent()
        discardButtonEvent()
        recordButtonEvent()
        mapCenterButtonEvent()
        mapCenterUpdate()
        scaleCPMUpdate()
        validMeasurementUpdate()
        allMeasurementUpdate()
    }
    
    // Upload button
    private func uploadButtonEvent() {
        uploadCocoaAction = CocoaAction(viewModel.uploadAction!, input:nil)
        uploadButton.addTarget(uploadCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Discard button
    private func discardButtonEvent() {
        discardButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                let alertController = UIAlertController(title: nil, message: "Are you sure you want discard these measurements?", preferredStyle: .ActionSheet)
                let destroyAction   = UIAlertAction(title: "Discard", style: .Destructive) { (action) in
                    self.viewModel.discardAllMeasurements()
                }
                
                alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
                alertController.addAction(destroyAction)
                
                self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    // Record button
    private func recordButtonEvent() {
        recordButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                // Presents the recording screen
                let recordController = UIStoryboard.Scene.Main.recordViewController()
                
                self.tabBarController?.presentViewController(recordController, animated: true, completion: nil)
        }
    }
    
    // Center the map to display all measurements when button touched
    private func mapCenterButtonEvent() {
        centerMapButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                self.centerMap(true)
        }
    }
    
    // Center the map
    private func mapCenterUpdate() {
        viewModel.mapCenterCoordinate.producer.startWithNext { coordinate in
            guard let coordinate = coordinate else {
                return
            }
            
            self.mapView?.setCenterCoordinate(coordinate, animated: false)
        }
    }
    
    // Update the scale and display the value container
    private func scaleCPMUpdate() {
        viewModel.measurementScaleCPM.producer.startWithNext { cpm in
            self.measurementScaleView.cpm = cpm
            
            UIView.animateWithDuration(0.2, delay: 0, options: [.TransitionCrossDissolve, .BeginFromCurrentState],
                animations: {
                    self.valuesContainerView.alpha = 1.0
                    self.selectionView.alpha = 1.0
                }, completion: nil)
        }
    }
    
    // Update the graph and map overlay using provided valid measurements
    private func validMeasurementUpdate() {
        viewModel.validMeasurements.producer.startWithNext { measurements in
            guard let measurements = measurements else {
                return
            }
            
            let lut = SDCMeasurementColorLUT()
            
            let overlays = measurements
                .map { measurement -> SDCMeasurementOverlay in
                    let overlay     = SDCMeasurementOverlay(centerCoordinate: measurement.coordinate, radius: 2)
                    overlay.color   = lut.colorForValue(measurement.cpm)
                    
                    return overlay
            }
            
            self.multiMeasurementOverlay = SDCMultiMeasurementOverlay(measurements: overlays)
            
            self.measurementLineGraphView.delegate      = self.viewModel
            self.measurementLineGraphView.dataSource    = self.viewModel
            
            self.measurementLineGraphView.reloadGraph()
        }
    }
    
    // Updates text with number of measurements
    private func allMeasurementUpdate() {
        viewModel.allMeasurements.producer.startWithNext { measurements in
            guard let measurements = measurements else {
                return
            }
            
            self.uploadView.hidden = measurements.count > 0 ? false : true
        }
    }
}

// MARK - Map
extension SDCUploadViewController {
    
    // Load the map everytime the view appears
    private func loadMap() {
        mapView = MKMapView()
        
        mapView!.pitchEnabled   = false
        mapView!.delegate       = self
        
        mapContainerView.insertSubview(mapView!, atIndex: 0)
        
        mapView!.snp_makeConstraints { make in
            make.edges.equalTo(mapContainerView)
        }
        
        // We need to listen to all gestures
        let gestures = [UITapGestureRecognizer(),
            UIPinchGestureRecognizer(),
            UIRotationGestureRecognizer(),
            UISwipeGestureRecognizer(),
            UIPanGestureRecognizer()]
        
        for gesture in gestures {
            gesture.delegate = self
            
            mapView!.addGestureRecognizer(gesture)
        }
        
        // Adding the dim overlay
        var points = [MKMapPoint(x: MKMapRectWorld.origin.x, y: MKMapRectWorld.origin.y),
            MKMapPoint(x: MKMapRectWorld.origin.x + MKMapRectWorld.size.width, y: MKMapRectWorld.origin.y),
            MKMapPoint(x: MKMapRectWorld.origin.x + MKMapRectWorld.size.width, y: MKMapRectWorld.origin.y + MKMapRectWorld.size.height),
            MKMapPoint(x: MKMapRectWorld.origin.x, y: MKMapRectWorld.origin.y + MKMapRectWorld.size.height)]
        
        dimOverlay      = MKPolygon(points: &points, count: points.count)
        mapView!.alpha  = 0
        
        // Display the map with a fade in animation
        UIView.animateWithDuration(1.0, delay:0.5, options: .TransitionCrossDissolve, animations: {
            self.mapView!.alpha = 1
            }, completion: nil)
        
        // Hide unnecessary elements of the interface
        valuesContainerView.alpha   = 0.0
        selectionView.alpha         = 0.0
    }
    
    // Unload the map everytime the view disappears
    private func unloadMap() {
        multiMeasurementOverlay = nil
        dimOverlay              = nil
        
        // Clears the tile cache
        mapView?.mapType        = .Hybrid
        
        mapView?.removeFromSuperview()
        
        mapView?.delegate       = nil
        mapView                 = nil
    }
    
    // Center the map making every measurement visible
    private func centerMap(animated: Bool) {
        
        if let multiMeasurementOverlay = multiMeasurementOverlay {
            let boundingMapRect = multiMeasurementOverlay.boundingMapRect
            let visibleRect = MKMapRectMake(boundingMapRect.origin.x - boundingMapRect.size.width * 0.2,
                boundingMapRect.origin.y - boundingMapRect.size.height * 0.2,
                boundingMapRect.size.width * 1.4,
                boundingMapRect.size.height * 1.4)
            
            mapView?.setVisibleMapRect(visibleRect, animated: animated)
            
            UIView.animateWithDuration(0.2, delay: 0, options: [.TransitionCrossDissolve, .BeginFromCurrentState],
                animations: {
                    self.valuesContainerView.alpha = 0.0
                    self.selectionView.alpha = 0.0
                }, completion: nil)
            
            measurementScaleView.cpm    = 01
        }
    }
}

// MARK - MKMapViewDelegate
extension SDCUploadViewController: MKMapViewDelegate {
    
    // Render the mesurements and dim overlays
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

// MARK: - UIGestureRecognizer methods
extension SDCUploadViewController: UIGestureRecognizerDelegate {
    
    // Hide unnecessary elements of the interface when users makes gesture on the map
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        UIView.animateWithDuration(0.2, delay: 0, options: [.TransitionCrossDissolve, .BeginFromCurrentState],
            animations: {
                self.valuesContainerView.alpha = 0.0
                self.selectionView.alpha = 0.0
            }, completion: nil)
        
        measurementScaleView.cpm    = 0
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
