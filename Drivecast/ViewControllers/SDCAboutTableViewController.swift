//
//  SDCAboutViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCAboutTableViewController: UITableViewController {
    
    // ViewModel handling all logic
    let viewModel   = SDCAboutViewModel()
    
    // IB variables
    @IBOutlet var buildLabel: UILabel!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var volunteerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCAboutTableViewController {
    
    func configureView() {
        view.backgroundColor = UIColor(named: .Background)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .Done,
            target: self,
            action: #selector(SDCAboutTableViewController.closeAbout)
        )
        
        donateButton.isRounded          = true
        volunteerButton.isRounded       = true
        donateButton.backgroundColor    = UIColor(named: .Main)
        volunteerButton.backgroundColor = UIColor(named: .Main)
    }
    
    func closeAbout() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCAboutTableViewController {
    
    func bindViewModel() {
        buildLabel.rac_text <~ viewModel.buildString
    }
}

// MARK - UITableViewDelegate
extension SDCAboutTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.showDetails(indexPath, viewController: self)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}