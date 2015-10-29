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
    
    // ViewModel from the parent screen handling all logic
    var viewModel: SDCRecordViewModel?
    
    // IB variable
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCConsoleViewController {
    func configureView() {
        view.backgroundColor            = UIColor(named: .Background)
        tableView.backgroundColor       = view.backgroundColor
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44.0
        tableView.dataSource            = self
    }
}

// MARK - Signal Bindings
extension SDCConsoleViewController {
    func bindViewModel() {
        if let viewModel = viewModel {
            viewModel.consoleArray.producer.startWithNext { array in
                let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            }
        }
    }
}

// MARK - UITableViewDataSource
extension SDCConsoleViewController: UITableViewDataSource {

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.consoleArray.value.count ?? 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell    = tableView.dequeueReusableCellWithIdentifier(
            SDCConsoleLogEntryCell.identifier,
            forIndexPath: indexPath) as! SDCConsoleLogEntryCell
        
        let array   = viewModel?.consoleArray.value ?? []
        let entry   = array[array.count - indexPath.row - 1]
        
        cell.lineLabel?.text       = entry.text
        cell.lineLabel?.textColor  = entry.color
        
        return cell
    }
}