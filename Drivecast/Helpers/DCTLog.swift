//
//  SDCLog.swift
//  safecaster
//
//  Created by Marc Rollin on 4/11/15.
//  Copyright (c) 2015 safecast. All rights reserved.
//

import Foundation

// Log function displaying details about the dumped object
func dlog<T>(object: T, filename: NSString = #file, line: Int = #line, funcname: String = #function) {
    #if DEBUG
        print(">>> \(filename.lastPathComponent)(\(line)) \(funcname):")
        dump(object)
        print("")
    #endif
}