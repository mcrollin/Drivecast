//
//  SDCConfiguration.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation

/**
    Struct providing simple configuration.
*/
struct SDCConfiguration {
    
    #if STAGING
    // Safecast's staging API's base URL
    static let apiBaseURL   = "http://dev.safecast.org/en-US"

    #else
    // Safecast's production API's base URL
    static let apiBaseURL   = "https://api.safecast.org/en-US"
    
    #endif
}