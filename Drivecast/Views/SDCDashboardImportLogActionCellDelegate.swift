//
//  SDCDashboardImportLogActionCellDelegate.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/29/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

protocol SDCDashboardImportLogActionCellDelegate {
    func executeImportLogAction(importLog: SDCImportLog)
}

class SDCDashboardImportLogActionCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier       = "ImportLogAction"
    var delegate: SDCDashboardImportLogActionCellDelegate? = nil
    
    // IB variable
    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
                .subscribeNext { _ in
                    delegate?.executeImportLogAction(self.importLog)
            }
        }
    }
    
    var importLog: SDCImportLog! {
        didSet {
            actionButton.backgroundColor    = UIColor(named: .Main)
            actionButton.isRounded          = true
            
            actionButton.setTitle(importLog.actionTitle.uppercaseString, forState: .Normal)
        }
    }
}
