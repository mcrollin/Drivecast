//
//  SDCDashboardImportLogOpenMapCell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/29/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

class SDCDashboardImportLogOpenMapCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier   = "ImportLogOpenMap"
    
    // IB variable
    @IBOutlet var mapLabel: UILabel!
    
    var importLog: SDCImport! {
        didSet {
            mapLabel.textColor  = UIColor(named: .Text)
        }
    }
}