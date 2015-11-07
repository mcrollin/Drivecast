//
//  SDCLog.swift
//  safecaster
//
//  Created by Marc Rollin on 4/11/15.
//  Copyright (c) 2015 safecast. All rights reserved.
//

import Foundation

// Log function displaying details about the dumped object
func log<T>(object: T, filename: NSString = __FILE__, line: Int = __LINE__, funcname: String = __FUNCTION__) {
    print(">>> \(filename.lastPathComponent)(\(line)) \(funcname):")
    dump(object)
    print("")
}