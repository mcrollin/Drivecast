//
//  JSONDecodable.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/15/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import SwiftyJSON

protocol JSONDecodable {
    static func json(json: JSON) -> Self
}