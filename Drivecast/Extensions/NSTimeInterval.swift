//
//  NSTimeInterval.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation

extension NSTimeInterval {
    
    func clockString() -> String {
        let calendar = NSCalendar.currentCalendar()
        let referenceDate = NSDate()
        let date = NSDate(timeInterval: self, sinceDate:referenceDate)
        let flags: NSCalendarUnit = [NSCalendarUnit.Hour, NSCalendarUnit.Minute, NSCalendarUnit.Second]
        let components = calendar.components(flags, fromDate: referenceDate, toDate: date, options:[])
        
        return String(format: "%02d:%02d:%02d", components.hour, components.minute, components.second)
    }
}