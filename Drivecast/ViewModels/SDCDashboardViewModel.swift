//
//  SDCDashboardViewModel.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import ReactiveCocoa
import KVNProgress
import RealmSwift

struct SDCDashboardViewModel {
    
    let importLogs              = MutableProperty<Results<SDCImport>?>(nil)
    let usernameString          = MutableProperty<String>("")
    let measurementCountString  = MutableProperty<String>("")
    let signOutButtonString     = MutableProperty<String>("")
    
    private var page    = 1
    
    init() {
        retrieveNextPage()
    }
}

extension SDCDashboardViewModel {
    private func updateImportLogs() {
        let realm           = try! Realm()
        importLogs.value    = realm.objects(SDCImport)
    }
    
    private func updateUser() {
        guard let user = SDCUser.authenticatedUser else {
            return
        }
        
        let formatter                   = NSNumberFormatter()
        formatter.numberStyle           = .DecimalStyle
        usernameString.value            = "Welcome \(user.name)"
        measurementCountString.value    = formatter.stringFromNumber(user.approvedMeasurementCount)!
        signOutButtonString.value       = "Not \(user.name)?".uppercaseString
    }
    
    private mutating func retrieveNextPage() {
        guard let user = SDCUser.authenticatedUser else {
            return
        }
        
        updateUser()
        
        SDCSafecastAPI.retrieveImports(user.id, page: page) { result in
            switch result {
            case .Success(let imports):
                for importLog in imports {
                    importLog.update()
                }
                
                self.updateImportLogs()
            case .Failure(let error):
                log(error)
            }
        }
    }
}

extension SDCDashboardViewModel {
    private func updateImport(importId: Int) {
        KVNProgress.show()
        
        SDCSafecastAPI.retrieveImport(importId) { result in
            switch result {
            case .Success(let importLog):
                importLog.update()
                
                self.updateImportLogs()
                
                KVNProgress.showSuccess()
            case .Failure(let error):
                log(error)
                
                KVNProgress.showError()
            }
        }
    }
    
    private func submitImport(importId: Int, key: String) {
        KVNProgress.show()
        
        SDCSafecastAPI.submitImport(importId, key: key) { result in
            switch result {
            case .Success(let importLog):
                importLog.update()
                
                self.updateImportLogs()
                
                KVNProgress.showSuccess()
            case .Failure(let error):
                log(error)
                
                KVNProgress.showError()
            }
        }
    }
    
    func executeAction(importLog: SDCImport) {
        guard let user = SDCUser.authenticatedUser where importLog.hasAction else {
            return
        }
        
        switch importLog.progress {
        case .Uploaded:
            return updateImport(importLog.id)
        case .MetadataAdded:
            return submitImport(importLog.id, key: user.key)
        default:
            break
        }
        
    }
    
    func executeMetadataAction(importLog: SDCImport, cities: String, credits: String, description: String) {
        guard let user = SDCUser.authenticatedUser
            where importLog.hasAction && importLog.progress == .Processed else {
            return
        }
        
        KVNProgress.show()
        
        SDCSafecastAPI.editImportMetadata(importLog.id, key: user.key,
            cities: cities, credits: credits, description: description) { result in
                switch result {
                case .Success(let importLog):
                    importLog.update()
                    
                    self.updateImportLogs()
                    
                    KVNProgress.showSuccess()
                case .Failure(let error):
                    log(error)
                    
                    KVNProgress.showError()
                }
        }
    }
}