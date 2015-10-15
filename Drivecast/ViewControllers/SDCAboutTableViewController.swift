//
//  SDCAboutViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

// http://blog.safecast.org/bgeigie-nano/
class SDCAboutTableViewController: UITableViewController {
    let viewModel   = SDCAboutViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCAboutTableViewController {
    func configureView() {
        self.view.backgroundColor = UIColor(named: .Background)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: Selector("closeAbout")
        )
    }
    
    func closeAbout() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCAboutTableViewController {
    func bindViewModel() {
    }
}
