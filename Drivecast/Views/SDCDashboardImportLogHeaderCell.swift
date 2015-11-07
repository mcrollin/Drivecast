//
//  SDCDashboardImportLogHeaderCell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/28/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

class SDCDashboardImportLogHeaderCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier   = "ImportLogHeader"
    
    // IB variables
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusContainerView: UIView!
    
    var importLog: SDCImportLog! {
        didSet {
            let timeZone    = NSTimeZone.localTimeZone()
            let formatter   = NSDateFormatter()
            
            formatter.timeZone  = timeZone
            formatter.dateStyle = .MediumStyle
            
            var subtitle    = formatter.stringFromDate(importLog.createdAt)
            
            if (importLog.credits != ""
                && importLog.cities != "") {
                    subtitle += " - \(importLog.credits) @ \(importLog.cities)"
            }
            
            titleLabel.text             = importLog.name
            titleLabel.textColor        = UIColor(named: .Text)
            subtitleLabel.text          = subtitle
            subtitleLabel.textColor     = UIColor(named: .LightText)
            statusLabel.text            = importLog.status.uppercaseString
            
            var color: UIColor!
            
            if importLog.progress == .Live {
                color = UIColor(named: .Main)
            } else if importLog.progress == .Rejected {
                color = UIColor(named: .Notice)
            } else {
                color = UIColor(named: .Awaiting)
            }
            
            statusLabel.textColor = color.colorWithAlphaComponent(0.8)
            statusContainerView.backgroundColor = color.colorWithAlphaComponent(0.1)
            statusContainerView.layer.cornerRadius = 10
            statusContainerView.layer.borderColor = color.colorWithAlphaComponent(0.5).CGColor
            statusContainerView.layer.borderWidth   = 1
            statusContainerView.clipsToBounds = true
        }
    }
}
