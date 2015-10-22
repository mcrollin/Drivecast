//
//  SDCRecordViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/5/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SpinKit
import SnapKit

class SDCRecordViewController: UIViewController {
    
    // ViewModel handling all logic
    let viewModel   = SDCRecordViewModel()
    
    // Activity monitor spinner
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StyleArcAlt, color: UIColor(named: .Main))
    
    // Toggle recording action
    var toggleRecordingCocoaAction: CocoaAction!
    
    // IB variables
    @IBOutlet var activityDetailsLabel: UILabel!
    @IBOutlet var recordView: UIView!
    @IBOutlet var noticeView: UIView!
    @IBOutlet var noticeLabel: UILabel!
    @IBOutlet var cpmLabel: UILabel!
    @IBOutlet var cpmUnitLabel: UILabel!
    @IBOutlet var usvhLabel: UILabel!
    @IBOutlet var usvhUnitLabel: UILabel!
    @IBOutlet var measurementCircleView: SDCMeasurementCircleView!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var countDescriptionLabel: UILabel!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var distanceDescriptionLabel: UILabel!
    @IBOutlet var separatorView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.connect()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCRecordViewController {
    func configureView() {
        let textColor                       = UIColor(named: .Text)
        let lightTextColor                  = UIColor(named: .LightText)
        
        view.backgroundColor                = UIColor(named: .Background)
        activityDetailsLabel.textColor      = textColor
        cpmLabel.textColor                  = textColor
        cpmUnitLabel.textColor              = lightTextColor
        usvhLabel.textColor                 = textColor
        usvhUnitLabel.textColor             = lightTextColor
        countLabel.textColor                = textColor
        countDescriptionLabel.textColor     = lightTextColor
        distanceLabel.textColor             = textColor
        distanceDescriptionLabel.textColor  = lightTextColor
        recordView.alpha                    = 0.0
        noticeView.alpha                    = 0.0
        noticeView.isRounded                = true
        noticeView.backgroundColor          = UIColor(named: .Notice).colorWithAlphaComponent(0.7)
        actionButton.isRounded              = true
        actionButton.backgroundColor        = UIColor(named: .Main)
        separatorView.backgroundColor       = UIColor(named: .Separator)
        
        // Left button opens a console listing all occuring events
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.Console.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openConsole")
        )

        // Add the activity monitor to the screen
        view.addSubview(activityMonitor)
        
        activityMonitor.startAnimating()
        activityMonitor.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
    }
    
    // Cancels the connection and dismisses the current screen
    func cancelConnection() {
        viewModel.disconnect()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Displays a console of events
    func openConsole() {
        let console = UIStoryboard.Segue.Main.OpenConsole.rawValue
    
        performSegueWithIdentifier(console, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch UIStoryboard.Segue.Main(rawValue: segue.identifier!)! {
            case .OpenConsole:
            // Pass down the current viewModel to display logs from this screen
            let controller = segue.destinationViewController as! SDCConsoleViewController
            
            controller.viewModel = viewModel
        }
    }
}

// MARK - Signal Bindings
extension SDCRecordViewController {
    
    func bindViewModel() {
        rac_title                       <~ viewModel.title
        activityDetailsLabel.rac_text   <~ viewModel.activityDetailsString
        cpmLabel.rac_text               <~ viewModel.cpmString
        usvhLabel.rac_text              <~ viewModel.usvhString
        countLabel.rac_text             <~ viewModel.countString
        distanceLabel.rac_text          <~ viewModel.distanceString
        durationLabel.rac_text          <~ viewModel.durationString
        actionButton.rac_title          <~ viewModel.actionButtonString
        noticeLabel.rac_text            <~ viewModel.noticeString
        
        // Binding the signIn action
        toggleRecordingCocoaAction = CocoaAction(viewModel.toggleRecordingAction!, input:nil)
        actionButton.addTarget(toggleRecordingCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
        
        viewModel.lastMeasurement.producer
            .startWithNext { measurement in
                guard let measurement = measurement else {
                    return
                }
                
                // Updates the measurement circle value
                self.measurementCircleView.cpm  = measurement.cpm
        }
        
        // Display/Hide a notice message when needed
        viewModel.noticeIsVisible.producer
            .skip(1)
            .skipRepeats()
            .startWithNext { visible in
                if visible {
                    UIView.animateWithDuration(0.3, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.noticeView.alpha    = 1.0
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.3, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.noticeView.alpha    = 0.0
                        }, completion: nil)
                }
        }
        
        // Switches between the connection and record screens
        viewModel.isReadyToRecord.producer
            .skipRepeats()
            .startWithNext { ready in
                // Update the cancel connection button title if connected/disconnected
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: ready ? .Done : .Cancel,
                    target: self,
                    action: Selector("cancelConnection")
                )
                
                // Switch views between connection and recording
                if ready {
                    self.activityMonitor.stopAnimating()
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha           = 1.0
                            self.activityDetailsLabel.alpha = 0.0
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha           = 0.0
                            self.activityDetailsLabel.alpha = 1.0
                        }, completion: { _ in
                            self.activityMonitor.startAnimating()
                    })
                                        
                }
        }
        
        viewModel.isRecording.producer
            .skipRepeats()
            .startWithNext { recording in
                self.durationLabel.textColor = UIColor(named: recording ? .Text : .LightText)
        }
    }
}