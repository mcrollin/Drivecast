//
//  SDCDashboardViewController.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa
import SafariServices
import SpinKit
import SnapKit

class SDCDashboardTableViewController: UITableViewController {
    
    // ViewModel handling all logic
    var viewModel   = SDCDashboardViewModel()
    
    private var isLoadingNextPage = false
    
    // Activity monitor spinner
    let refreshMonitor:RTSpinKitView = RTSpinKitView(style: .StyleBounce,
        color: UIColor(named: .Main).colorWithAlphaComponent(0.2))
    let activityMonitor:RTSpinKitView = RTSpinKitView(style: .StyleBounce,
        color: UIColor(named: .Main).colorWithAlphaComponent(0.2))
    let nextPageMonitor:RTSpinKitView = RTSpinKitView(style: .StyleBounce,
        color: UIColor(named: .Main).colorWithAlphaComponent(0.2))
    
    // IB variable
    @IBOutlet var headerView: UIView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var measurementCountLabel: UILabel!
    @IBOutlet var measurementCountDescriptionLabel: UILabel!
    @IBOutlet var signOutButton: UIButton!
    @IBOutlet var footerView: UIView!
    @IBOutlet var recordButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureView()
        bindViewModel()
        
        viewModel.getUserInformation { _ in }
        viewModel.getFirstPage { _ in }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.updateUser()
        viewModel.updateImportLogs()
    }
}

// MARK - UIView
extension SDCDashboardTableViewController {
    
    func configureView() {
        // Title
        navigationItem.titleView    = UIImageView(image: UIImage(asset: .SafecastLettersSmall))
        
        // Backgrounds
        tableView.backgroundColor   = UIColor(named: .Background)
        headerView.backgroundColor  = UIColor(named: .Background)
        
        // Labels
        usernameLabel.textColor                     = UIColor(named: .Text)
        measurementCountLabel.textColor             = UIColor(named: .Text)
        measurementCountDescriptionLabel.textColor  = UIColor(named: .LightText)
        
        // Sign out button
        signOutButton.setTitleColor(UIColor(named: .Main), forState: .Normal)
        
        // Navigation button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage.Asset.More.image,
            style: UIBarButtonItemStyle.Plain,
            target: self, action: Selector("openAboutModal")
        )
        
        // Table view
        tableView.rowHeight             = UITableViewAutomaticDimension
        tableView.estimatedRowHeight    = 44.0
        
        // Record button
        recordButton.backgroundColor    = UIColor(named: .Main)
        view.addSubview(recordButton)
        
        // Refresh control
        refreshControl?.addSubview(refreshMonitor)
        refreshControl?.tintColor   = UIColor.clearColor()
        
        refreshMonitor.snp_makeConstraints { make in
            make.center.equalTo(refreshControl!)
        }
        
        // Activity monitor
        view.addSubview(activityMonitor)
        
        activityMonitor.snp_makeConstraints { make in
            make.center.equalTo(view)
        }
        
        activityMonitor.startAnimating()
        
        // Footer
        footerView.addSubview(nextPageMonitor)
        
        nextPageMonitor.snp_makeConstraints { make in
            make.centerX.equalTo(footerView)
            make.top.equalTo(0)
        }
    }
    
    func deauthenticate() {
        viewModel.deauthenticateUser()
        
        tabBarController?.navigationController?.popViewControllerAnimated(true)
    }
    
    func openAboutModal() {
        let about = StoryboardScene.Main.aboutViewController()
        
        presentViewController(about, animated: true, completion: nil)
    }
    
    @IBAction func refresh(sender: AnyObject) {
        refreshControl?.tintColor   = UIColor.clearColor()
        
        if let refreshControl = refreshControl where !refreshControl.refreshing {
            refreshControl.performSelector(Selector("beginRefreshing"), withObject: nil, afterDelay: 0.05)
        }
        
        viewModel.getFirstPage { _ in }
    }
}

// MARK - Signal Bindings
extension SDCDashboardTableViewController {
    
    func bindViewModel() {
        usernameLabel.rac_text          <~ viewModel.usernameString
        measurementCountLabel.rac_text  <~ viewModel.measurementCountString
        signOutButton.rac_title         <~ viewModel.signOutButtonString
    
        lastPage()
        updatedImportLogs()
        signOutButtonEvent()
        recordButtonEvent()
    }
    
    // Last page
    private func lastPage() {
        viewModel.isLastPage.producer.startWithNext { isLastPage in
            if isLastPage {
                self.nextPageMonitor.stopAnimating()
            } else {
                self.nextPageMonitor.startAnimating()
            }
        }
    }
    
    // Updated import logs
    private func updatedImportLogs() {
        viewModel.importLogs.producer.startWithNext { importLogs in
            if self.activityMonitor.isAnimating() {
                self.activityMonitor.stopAnimating()
            }
            
            if importLogs?.count == 0 {
                self.recordButton.isRounded = true
                self.recordButton.hidden    = false
                self.recordButton.snp_makeConstraints { make in
                    make.center.equalTo(self.view)
                }
            } else {
                self.recordButton.hidden    = true
                self.recordButton.snp_removeConstraints()
            }
            
            self.tableView.reloadData()
            
            if let refreshControl = self.refreshControl where refreshControl.refreshing {
                refreshControl.performSelector(Selector("endRefreshing"), withObject: nil, afterDelay: 0.05)
            }
        }
    }
    
    // Signout button
    private func signOutButtonEvent() {
        signOutButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .ActionSheet)
                let destroyAction   = UIAlertAction(title: "Sign out", style: .Destructive) { (action) in
                    self.deauthenticate()
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
                let recordController = StoryboardScene.Main.recordViewController()
                
                self.tabBarController?.presentViewController(recordController, animated: true, completion: nil)
        }
    }
}

// MARK - SDCDashboardImportLogActionCellDelegate
extension SDCDashboardTableViewController: SDCDashboardImportLogActionCellDelegate {
    
    func executeImportLogAction(importLog: SDCImportLog) {
        viewModel.executeAction(importLog)
    }
}

// MARK - SDCDashboardImportLogMetadataActionCellDelegate
extension SDCDashboardTableViewController: SDCDashboardImportLogMetadataActionCellDelegate {
    
    func executeMetadataImportLogAction(importLog: SDCImportLog, cities: String, credits: String, name: String, description: String) {
        viewModel.executeMetadataAction(importLog, cities: cities, credits: credits, name: name, description: description)
    }
}

// MARK - UIScrollViewDelegate
extension SDCDashboardTableViewController {
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if !viewModel.isLastPage.value
            && scrollView.contentSize.height - scrollView.contentOffset.y
            < 2 * CGRectGetHeight(scrollView.bounds) {
                if isLoadingNextPage {
                    return
                }
                
                isLoadingNextPage = true
                
                viewModel.getNextPage { _ in
                    self.isLoadingNextPage = false
                }
        }
    }
}

// MARK - UITableViewDataSource
extension SDCDashboardTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.importLogs.value?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let array       = viewModel.importLogs.value!
        let importLog   = array[section]
        var count       = 3
        
        if importLog.details != "" {
            count++
        }
        
        if importLog.hasAction {
            count++
        }
        
        return count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let array       = viewModel.importLogs.value!
        let importLog   = array[indexPath.section]
        let count       = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        var cell: SDCDashboardImportLogCell!
        
        if indexPath.row == 0 { // Header with Name, Date, Credits, Cities and Status
            cell    = tableView.dequeueReusableCellWithIdentifier(
                SDCDashboardImportLogHeaderCell.identifier,
                forIndexPath: indexPath) as! SDCDashboardImportLogHeaderCell
            
        } else if indexPath.row == 1 && importLog.details != "" { // Displays the details
            cell    = tableView.dequeueReusableCellWithIdentifier(
                SDCDashboardImportLogDetailsCell.identifier,
                forIndexPath: indexPath) as! SDCDashboardImportLogDetailsCell
            
        } else if indexPath.row == count - 1 && importLog.hasAction { // If an action is available on the log import
            
            if importLog.progress == .Processed { // Prompts fiels for metadata and a button to submit them
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogMetadataActionCell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogMetadataActionCell
                
                (cell as! SDCDashboardImportLogMetadataActionCell).delegate = self
                
            } else { // Otherwise prompts an action button alone
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogActionCell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogActionCell
                
                (cell as! SDCDashboardImportLogActionCell).delegate     = self
            }
            
        } else { // Then displays a link to the API
            if indexPath.row == count - (importLog.hasAction ? 2 : 1) {
                cell    = tableView.dequeueReusableCellWithIdentifier(
                    SDCDashboardImportLogOpenAPICell.identifier,
                    forIndexPath: indexPath) as! SDCDashboardImportLogOpenAPICell
                
            } else { // And one to the map
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
extension SDCDashboardTableViewController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let array       = viewModel.importLogs.value!
        let importLog   = array[indexPath.section]
        let count       = self.tableView(tableView, numberOfRowsInSection: indexPath.section)
        
        if indexPath.row == 0
        || (indexPath.row == 1 && importLog.details != "")
        || (indexPath.row == count - 1 && importLog.hasAction) {
            return
        }
        
        var urlString: String!
        
        if indexPath.row == count - (importLog.hasAction ? 2 : 1) {
            urlString   = "\(SDCConfiguration.API.baseURL)/bgeigie_imports/\(importLog.id)"
        } else {
            urlString   = "\(SDCConfiguration.Map.baseURL)/?z=3&l=11&m=4&logids=\(importLog.id)"
        }
        
        if let url = NSURL(string: urlString) {
            if #available(iOS 9.0, *) {
                let safari = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
                
                presentViewController(safari, animated: true, completion: nil)
            } else {
                UIApplication.sharedApplication().openURL(url)
            }
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == numberOfSectionsInTableView(tableView) {
            return 1
        }

        return 20
    }
}