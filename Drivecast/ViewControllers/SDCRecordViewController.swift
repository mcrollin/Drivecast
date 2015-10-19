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
    let viewModel   = SDCRecordViewModel()
    
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StyleArcAlt, color: UIColor(named: .Main))
    
    @IBOutlet var recordView: UIView!
    @IBOutlet var cpmLabel: UILabel!
    
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
        self.view.backgroundColor   = UIColor(named: .Background)
        self.recordView.alpha       = 0.0
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.Console.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openConsole")
        )

        view.addSubview(activityMonitor)
        
        activityMonitor.startAnimating()
        activityMonitor.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
    }
    
    func cancelConnection() {
        viewModel.disconnect()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func openConsole() {
        let console = UIStoryboard.Segue.Main.OpenConsole.rawValue
    
        performSegueWithIdentifier(console, sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch UIStoryboard.Segue.Main(rawValue: segue.identifier!)! {
            case .OpenConsole:
            let controller = segue.destinationViewController as! SDCConsoleViewController
            
            controller.viewModel = viewModel
        }
    }
}

// MARK - Signal Bindings
extension SDCRecordViewController {
    func bindViewModel() {
        rac_title           <~ viewModel.title
        cpmLabel.rac_text   <~ viewModel.cpmString
        
        viewModel.readyToRecord.producer
            .skipRepeats()
            .startWithNext { ready in
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                    barButtonSystemItem: ready ? .Done : .Cancel,
                    target: self,
                    action: Selector("cancelConnection")
                )
                
                if ready {
                    self.activityMonitor.stopAnimating()
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha = 1.0
                        }, completion: nil)
                } else {
                    UIView.animateWithDuration(0.5, delay: 0.0,
                        options: [.CurveEaseInOut],
                        animations: {
                            self.recordView.alpha = 0.0
                        }, completion: { _ in
                            self.activityMonitor.startAnimating()
                    })
                                        
                }
        }
    }
}