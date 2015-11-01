//
//  SDCDashboardImportLogDetailsCell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/28/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

class SDCDashboardImportLogDetailsCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier   = "ImportLogDetails"
    
    // IB variable
    @IBOutlet var detailLabel: UILabel!
    
    var importLog: SDCImportLog! {
        didSet {
            detailLabel.text        = importLog.details
            detailLabel.textColor   = UIColor(named: .Text)
        }
    }
}