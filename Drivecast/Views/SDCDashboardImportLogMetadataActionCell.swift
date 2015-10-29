//
//  SDCDashboardImportLogMetadataActionCell.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/29/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol SDCDashboardImportLogMetadataActionCellDelegate {
    func executeMetadataImportLogAction(importLog: SDCImport, cities: String, credits: String, description: String)
}

class SDCDashboardImportLogMetadataActionCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier       = "ImportLogMetadataAction"
    var delegate: SDCDashboardImportLogMetadataActionCellDelegate? = nil
    
    // IB variable
    @IBOutlet var citiesTextField: UITextField!
    @IBOutlet var creditsTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButtonSignal()
        }
    }
    
    var importLog: SDCImport! {
        didSet {
            actionButton.backgroundColor    = UIColor(named: .Main)
            actionButton.isRounded          = true
            
            actionButton.setTitle(importLog.actionTitle.uppercaseString, forState: .Normal)
            actionButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.3), forState: .Disabled)
            
            enableActionButton()
        }
    }
}

extension SDCDashboardImportLogMetadataActionCell {
    private func actionButtonSignal() {
        actionButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                delegate?.executeMetadataImportLogAction(
                    self.importLog,
                    cities: citiesTextField.text!,
                    credits: creditsTextField.text!,
                    description: descriptionTextField.text ?? ""
                )
        }
    }
    
    // Validates that the email and passwords are valid
    private func validateMetadata(cities: String, credits: String, description: String) -> Bool {
        if cities.characters.count < 1
            || credits.characters.count < 1
            || description.characters.count < 1 {
                return false
        }
        
        return true
    }
    
    // Enables the action button when cities, credits and description meets requirements
    private func enableActionButton() {
        let citiesSignalProducer        = citiesTextField.rac_text.producer
        let creditsSignalProducer       = creditsTextField.rac_text.producer
        let descriptionSignalProducer   = descriptionTextField.rac_text.producer
        
        actionButton.rac_enabled <~ combineLatest(citiesSignalProducer, creditsSignalProducer, descriptionSignalProducer)
            .map { cities, credits, description in
                return self.validateMetadata(cities, credits: credits, description: description)
        }
    }
}
