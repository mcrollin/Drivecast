//
//  JSONEncodable.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//


import Foundation
import SwiftyJSON

protocol JSONEncodable {
    func encode() -> JSON
}

extension JSONEncodable {
    var encodedObject: AnyObject {
        return self.encode().object
    }
}