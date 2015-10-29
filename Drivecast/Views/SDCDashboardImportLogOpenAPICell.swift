//
//  SDCDashboardImportLogOpenAPICell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/29/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit

class SDCDashboardImportLogOpenAPICell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier   = "ImportLogOpenAPI"
    
    // IB variable
    @IBOutlet var apiLabel: UILabel!
    
    var importLog: SDCImport! {
        didSet {
            apiLabel.textColor  = UIColor(named: .Text)
        }
    }
}