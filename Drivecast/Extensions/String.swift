//
//  String.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation

extension String {

    // Extract information from an string following a regexp pattern
    func regexpFind(pattern: String) -> String? {
        do {
            let regexp   = try NSRegularExpression(pattern: pattern, options: [])
            let match    = regexp.firstMatchInString(self, options: [], range: NSRange(location: 0, length: self.characters.count))
            
            if let matched = match {
                return (self as NSString).substringWithRange(matched.rangeAtIndex(1))
            }
        } catch {
            log(error)
        }
        
        return nil
    }
}