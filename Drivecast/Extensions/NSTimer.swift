//
//  NSTimer.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/20/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation

extension NSTimer {

    // Creates and schedules a repeating NSTimer instance
    class func schedule(repeatInterval interval: NSTimeInterval, handler: NSTimer! -> Void) -> NSTimer {
        let fireDate = interval + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, interval, 0, 0, handler)
        
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes)
        
        return timer
    }
}