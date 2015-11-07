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
    func executeMetadataImportLogAction(importLog: SDCImportLog, cities: String, credits: String, name: String, description: String)
}

class SDCDashboardImportLogMetadataActionCell: UITableViewCell, SDCDashboardImportLogCell {
    static let identifier       = "ImportLogMetadataAction"
    var delegate: SDCDashboardImportLogMetadataActionCellDelegate? = nil
    
    // IB variable
    @IBOutlet var citiesTextField: UITextField!
    @IBOutlet var creditsTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var descriptionTextField: UITextField!
    @IBOutlet var actionButton: UIButton! {
        didSet {
            actionButtonSignal()
        }
    }
    
    var importLog: SDCImportLog! {
        didSet {
            actionButton.backgroundColor    = UIColor(named: .Main)
            actionButton.isRounded          = true
            
            actionButton.setTitle(importLog.actionTitle.uppercaseString, forState: .Normal)
            actionButton.setTitleColor(UIColor.whiteColor().colorWithAlphaComponent(0.3), forState: .Disabled)
            
            citiesTextField.delegate        = self
            creditsTextField.delegate       = self
            nameTextField.delegate          = self
            descriptionTextField.delegate   = self
            
            enableActionButton()
        }
    }
}

extension SDCDashboardImportLogMetadataActionCell {
    
    // Called when an the action button is triggered
    private func actionButtonSignal() {
        actionButton.rac_signalForControlEvents(UIControlEvents.TouchUpInside)
            .subscribeNext { _ in
                self.delegate?.executeMetadataImportLogAction(
                    self.importLog,
                    cities: self.citiesTextField.text!,
                    credits: self.creditsTextField.text!,
                    name: self.nameTextField.text!,
                    description: self.descriptionTextField.text ?? ""
                )
        }
    }
    
    // Validates that the email and passwords are valid
    private func validateMetadata(cities: String, credits: String, name: String, description: String) -> Bool {
        if cities.characters.count < 1
            || credits.characters.count < 1
            || name.characters.count < 1
            || description.characters.count < 1 {
                return false
        }
        
        return true
    }
    
    // Enables the action button when cities, credits and description meets requirements
    private func enableActionButton() {
        let citiesSignalProducer        = citiesTextField.rac_text.producer
        let creditsSignalProducer       = creditsTextField.rac_text.producer
        let nameSignalProducer          = nameTextField.rac_text.producer
        let descriptionSignalProducer   = descriptionTextField.rac_text.producer
        
        actionButton.rac_enabled <~ combineLatest(citiesSignalProducer, creditsSignalProducer, nameSignalProducer, descriptionSignalProducer)
            .map { cities, credits, name, description in
                return self.validateMetadata(cities, credits: credits, name: name, description: description)
        }
    }
}

// Handle return key on keyboard
extension SDCDashboardImportLogMetadataActionCell: UITextFieldDelegate {
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        switch textField {
        case citiesTextField:
            creditsTextField.becomeFirstResponder()
        case creditsTextField:
            nameTextField.becomeFirstResponder()
        case nameTextField:
            descriptionTextField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        
        return true
    }
}
