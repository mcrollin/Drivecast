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

class SDCDashboardViewModel {
    
    let importLogs              = MutableProperty<Results<SDCImportLog>?>(nil)
    let usernameString          = MutableProperty<String>("")
    let measurementCountString  = MutableProperty<String>("")
    let signOutButtonString     = MutableProperty<String>("")
    let isLastPage              = MutableProperty<Bool>(true)
    
    private var page            = 1
}

extension SDCDashboardViewModel {
    func updateImportLogs() {
        let realm           = try! Realm()
        importLogs.value    = realm.objects(SDCImportLog).sorted("createdAt", ascending: false)
    }
    
    func updateUser() {
        guard let user = SDCUser.authenticatedUser else {
            return
        }
        
        let formatter                   = NSNumberFormatter()
        formatter.numberStyle           = .DecimalStyle
        usernameString.value            = "Welcome \(user.name)"
        measurementCountString.value    = formatter.stringFromNumber(user.approvedMeasurementCount)!
        signOutButtonString.value       = "Not \(user.name)?".uppercaseString
    }
    
    func deauthenticateUser() {
        SDCUser.authenticatedUser = nil

        deleteAllImportLogs()
    }
    
    private func deleteAllImportLogs() {
        let realm       = try! Realm()
        let importLogs  = realm.objects(SDCImportLog)
        
        // Delete all measurements
        try! realm.write {
            realm.delete(importLogs)
        }
    }
    
    func getUserInformation(completion: SDCSafecastAPI.ResultUser) {
        guard let user = SDCUser.authenticatedUser else {
            return
        }
        
        SDCSafecastAPI.retrieveUser(user.id, email: user.email, key: user.key) { result in
            switch result {
            case .Success(let user):
                dlog(user)

                self.updateUser()
            case .Failure(let error):
                dlog(error)
            }
            
            completion(result)
        }
    }
    
    func getFirstPage(completion: SDCSafecastAPI.ResultImportLogs) {
        page = 1
        
        getNextPage(completion)
    }
    
    func getNextPage(completion: SDCSafecastAPI.ResultImportLogs) {
        guard let user = SDCUser.authenticatedUser else {
            return
        }
        
        SDCSafecastAPI.retrieveImports(user.id, page: page) { result in
            switch result {
            case .Success(let importLogs):
                if self.page == 1 {
                    self.deleteAllImportLogs()
                    self.isLastPage.value  = false
                }
                
                if importLogs.count == 0 {
                    self.isLastPage.value  = true
                } else {
                    for importLog in importLogs {
                        importLog.update()
                    }
                }
                
                self.page += 1
                
                self.updateImportLogs()
            case .Failure(let error):
                dlog(error)
            }
            
            completion(result)
        }
    }
}

extension SDCDashboardViewModel {
    private func updateImportLog(importId: Int) {
        KVNProgress.show()
        
        SDCSafecastAPI.retrieveImport(importId) { result in
            switch result {
            case .Success(let importLog):
                importLog.update()
                
                self.updateImportLogs()
                
                KVNProgress.showSuccess()
            case .Failure(let error):
                dlog(error)
                
                KVNProgress.showError()
            }
        }
    }
    
    private func submitImportLog(importId: Int, key: String) {
        KVNProgress.show()
        
        SDCSafecastAPI.submitImportLog(importId, key: key) { result in
            switch result {
            case .Success(let importLog):
                importLog.update()
                
                self.updateImportLogs()
                
                KVNProgress.showSuccess()
            case .Failure(let error):
                dlog(error)
                
                KVNProgress.showError()
            }
        }
    }
    
    func executeAction(importLog: SDCImportLog) {
        guard let user = SDCUser.authenticatedUser where importLog.hasAction else {
            return
        }
        
        switch importLog.progress {
        case .Uploaded:
            return updateImportLog(importLog.id)
        case .MetadataAdded:
            return submitImportLog(importLog.id, key: user.key)
        default:
            break
        }
        
    }
    
    func executeMetadataAction(importLog: SDCImportLog, cities: String, credits: String, name: String, description: String) {
        guard let user = SDCUser.authenticatedUser
            where importLog.hasAction && importLog.progress == .Processed else {
            return
        }
        
        KVNProgress.show()
        
        SDCSafecastAPI.editImportLogMetadata(importLog.id, key: user.key,
            cities: cities, credits: credits, name: name, description: description) { result in
                switch result {
                case .Success(let importLog):
                    importLog.update()
                    
                    self.updateImportLogs()
                    
                    KVNProgress.showSuccess()
                case .Failure(let error):
                    dlog(error)
                    
                    KVNProgress.showError()
                }
        }
    }
}