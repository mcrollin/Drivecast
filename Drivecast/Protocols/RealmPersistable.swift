//
//  RealmPersistable.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmPersistable: Persistable {
}

extension RealmPersistable {
    private func persist(update:Bool = false) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(self as! Object, update: update)
        }
    }
    
    func add() {
        persist()
    }
    
    func update() {
        persist(true)
    }
}