//
//  SDCDashboardImportLogOpenMapCell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/31/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

class SDCDashboardImportLogOpenMapCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier   = "ImportLogOpenMap"
    
    // IB variable
    @IBOutlet var apiLabel: UILabel!
    
    var importLog: SDCImportLog! {
        didSet {
            apiLabel.textColor  = UIColor(named: .Text)
        }
    }
}