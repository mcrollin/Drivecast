//
//  SDCConsoleViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/18/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCConsoleViewController: UIViewController {
    var viewModel: SDCRecordViewModel?
    
    @IBOutlet var consoleTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCConsoleViewController {
    func configureView() {
        self.view.backgroundColor = UIColor(named: .Background)
    }
}

// MARK - Signal Bindings
extension SDCConsoleViewController {
    func bindViewModel() {
        if let viewModel = viewModel {
            consoleTextView.rac_attributed_text <~ viewModel.consoleText
        }
    }
}