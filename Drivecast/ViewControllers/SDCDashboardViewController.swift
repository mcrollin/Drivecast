//
//  SDCDashboardViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

class SDCDashboardViewController: UIViewController {
    
    // ViewModel handling all logic
    let viewModel   = SDCDashboardViewModel()
    
    // IB variable
    @IBOutlet var tableView: UITableView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var measurementCountLabel: UILabel!
    @IBOutlet var measurementCountDescriptionLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
    }
}

// MARK - UIView
extension SDCDashboardViewController {
    func configureView() {
        navigationItem.titleView   = UIImageView(image: UIImage(asset: .SafecastLettersSmall))
        view.backgroundColor       = UIColor(named: .Background)

        usernameLabel.textColor                     = UIColor(named: .Text)
        measurementCountLabel.textColor             = UIColor(named: .Text)
        measurementCountDescriptionLabel.textColor  = UIColor(named: .LightText)
        
        signOutButton.setTitleColor(UIColor(named: .Main), forState: .Normal)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
        
        #if DEBUG
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage.Asset.Dot.image,
                style: UIBarButtonItemStyle.Plain,
                target: self, action: Selector("deauthenticate")
            )
        #endif
        
        tableView.delegate              = self
        tableView.dataSource            = self
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44.0
    }
    
    func deauthenticate() {
        SDCUser.authenticatedUser = nil
        
        tabBarController?.navigationController?.popViewControllerAnimated(true)
    }
    
    func openAboutModal() {
        let about = UIStoryboard.Scene.Main.aboutViewController()
        
        presentViewController(about, animated: true, completion: nil)
    }
}

// MARK - Signal Bindings
extension SDCDashboardViewController {
    
    func bindViewModel() {
        usernameLabel.rac_text          <~ viewModel.usernameString
        measurementCountLabel.rac_text  <~ viewModel.measurementCountString
        signOutButton.rac_title         <~ viewModel.signOutButtonString
        
        viewModel.importLogs.producer.startWithNext { _ in
            self.tableView.reloadData()
        }
    }
}

// MARK - SDCDashboardImportLogActionCellDelegate
extension SDCDashboardViewController: SDCDashboardImportLogActionCellDelegate {
    func executeImportLogAction(importLog: SDCImport) {
        viewModel.executeAction(importLog)
    }
}

// MARK - SDCDashboardImportLogMetadataActionCellDelegate
extension SDCDashboardViewController: SDCDashboardImportLogMetadataActionCellDelegate {
    func executeMetadataImportLogAction(importLog: SDCImport, cities: String, credits: String, description: String) {
        viewModel.executeMetadataAction(importLog, cities: cities, credits: credits, description: description)
    }
}


// MARK - UITableViewDataSource
extension SDCDashboardViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.importLogs.value?.count ?? 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array       = viewModel.importLogs.value!
        let importLog   = array[section]
        var count       = 2
        
        if importLog.details != "" {
            count++
        }
        
        if importLog.hasAction {
            count++
        }
        
        if importLog.progress != .Uploaded {
            count++
        }
        
        return count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let array       = viewModel.importLogs.value!
        let importLog   = array[indexPath.section]
        var count       = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
       
        var cell: SDCDashboardImportLogCell!
        
        if indexPath.row == 0 {
            cell    = tableView.dequeueReusableCellWithIdentifier(
                SDCDashboardImportLogHeaderCell.identifier,
                forIndexPath: indexPath) as! SDCDashboardImportLogHeaderCell
            
        } else if indexPath.row == 1 && importLog.details != "" {
            cell    = tableView.dequeueReusableCellWithIdentifier(
                SDCDashboardImportLogDetailsCell.identifier,
                forIndexPath: indexPath) as! SDCDashboardImportLogDetailsCell
            
        } else if indexPath.row == count - 1 && importLog.hasAction {
            
            if importLog.progress == .Processed {
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogMetadataActionCell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogMetadataActionCell
                
                (cell as! SDCDashboardImportLogMetadataActionCell).delegate     = self

            } else {
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogActionCell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogActionCell
                
                (cell as! SDCDashboardImportLogActionCell).delegate     = self
            }

        } else {
            if importLog.hasAction {
                count--
            }
            
            if indexPath.row == count - 1 {
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogOpenAPICell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogOpenAPICell
                
            }  else  {
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogOpenMapCell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogOpenMapCell
            }
        }
        
        cell.importLog  = importLog
        
        return cell as! UITableViewCell
    }
}

// MARK - UITableViewDelegate
extension SDCDashboardViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 16
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
}