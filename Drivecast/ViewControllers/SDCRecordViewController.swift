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
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StyleBounce, color: UIColor(named: .Main).colorWithAlphaComponent(0.1))
    
    // Actions
    var toggleRecordingCocoaAction: CocoaAction!
    var simulateDeviceCocoaAction: CocoaAction!
    
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
    @IBOutlet var dotView: UIImageView!
    @IBOutlet var simulateButton: UIButton!
    
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
        simulateButton.backgroundColor      = UIColor(named: .Main)
        simulateButton.isRounded            = true
        
        // Left button opens a console listing all occuring events
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.Console.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: #selector(SDCRecordViewController.openConsole)
        )

        // Add the activity monitor to the screen
        view.addSubview(activityMonitor)
        
        activityMonitor.startAnimating()
        activityMonitor.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
        
        // Scaling labels for 6/6+ screens
        let device          = Device()
        var scale: CGFloat  = 1.0
        
        switch device {
        case .iPhone6, .iPhone6s:
            scale   = 1.2
        case .iPhone6Plus, .iPhone6sPlus:
            scale   = 1.4
        default:
            break
        }
    
        cpmLabel.font       = cpmLabel.font.fontWithSize(cpmLabel.font.pointSize * scale)
        cpmUnitLabel.font   = cpmUnitLabel.font.fontWithSize(cpmUnitLabel.font.pointSize * scale)
        usvhLabel.font      = usvhLabel.font.fontWithSize(usvhLabel.font.pointSize * scale)
        usvhUnitLabel.font  = usvhUnitLabel.font.fontWithSize(usvhUnitLabel.font.pointSize * scale)
    }
    
    // Cancels the connection and dismisses the current screen
    func cancelConnection() {
        viewModel.disconnect()
        
        // Shows the upload screen
        UIApplication.showTab(SDCConfiguration.UI.TabBarMenu.Upload)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Displays a console of events
    func openConsole() {
        let console = StoryboardSegue.Main.OpenConsole.rawValue
    
        performSegueWithIdentifier(console, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch StoryboardSegue.Main(rawValue: segue.identifier!)! {
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
        
        recordAction()
        simulateDeviceAction()
        lastMeasurement()
        noticeVisibility()
        readyToRecord()
        isRecording()
    }

    // Binding the record action
    private func recordAction() {
        toggleRecordingCocoaAction = CocoaAction(viewModel.toggleRecordingAction!, input:nil)
        actionButton.addTarget(toggleRecordingCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Binding the simulate device action
    private func simulateDeviceAction() {
        simulateDeviceCocoaAction = CocoaAction(viewModel.simulateDeviceAction!, input:nil)
        simulateButton.addTarget(simulateDeviceCocoaAction, action: CocoaAction.selector, forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // Last Measurement
    private func lastMeasurement() {
        viewModel.lastMeasurement.producer
            .startWithNext { measurement in
                guard let measurement = measurement else {
                    return
                }
                
                // Updates the measurement circle value
                self.measurementCircleView.cpm  = measurement.cpm
        }
    }
    
    // Display/Hide a notice message when needed
    private func noticeVisibility() {
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
    }
    
    
    // Switches between the connection and record screens
    private func readyToRecord() {
        viewModel.isReadyToRecord.producer
            .skipRepeats()
            .startWithNext { ready in
                // Update the cancel connection button title if connected/disconnected
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: ready ? .Done : .Cancel,
                    target: self,
                    action: #selector(SDCRecordViewController.cancelConnection)
                )
                
                // Switch views between connection and recording
                if ready {
                    self.activityMonitor.stopAnimating()
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha           = 1.0
                            self.activityDetailsLabel.alpha = 0.0
                            self.dotView.alpha              = 0.0
                        }, completion: nil)
                    
                    #if DEBUG
                        self.simulateButton.hidden  = true
                    #endif
                } else {
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha           = 0.0
                            self.activityDetailsLabel.alpha = 1.0
                            self.dotView.alpha              = 1.0
                        }, completion: { _ in
                            self.activityMonitor.startAnimating()
                    })
                    
                    #if DEBUG
                        self.simulateButton.hidden  = false
                    #endif
                }
        }
    }
    
    private func isRecording() {
        viewModel.isRecording.producer
            .skipRepeats()
            .startWithNext { recording in
                self.durationLabel.textColor        = UIColor(named: recording ? .Text : .LightText)
                self.actionButton.backgroundColor   = UIColor(named: recording ? .Notice : .Main)
        }
    }
}