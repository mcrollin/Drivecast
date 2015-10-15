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
        self.view.backgroundColor = UIColor(named: .Background)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Cancel,
            target: self,
            action: Selector("cancelConnection")
        )

        activityMonitor.startAnimating()
        view.addSubview(activityMonitor)
        activityMonitor.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self.view)
        }
    }
    
    func cancelConnection() {
        viewModel.disconnect()
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCRecordViewController {
    func bindViewModel() {
        DynamicProperty(object: self, keyPath: "title") <~ viewModel.title.producer.map {$0}
        
        viewModel.title.producer
            .start { event in
                switch event {
                case let .Next(value):
                    print(value)
                default:
                    break
                }
        }
    }
}