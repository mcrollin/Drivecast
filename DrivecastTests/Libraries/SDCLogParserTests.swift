//
//  SDCLogParserTests.swift
//  Drivecast
//
//  Created by Marc Rollin on 11/16/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import XCTest

class SDCLogParserTests: XCTestCase {
    
    func testParseMeasurementData() {
        let measurementData = "$BNRDD,0210,2013-04-11T05:40:51Z,35,0,736,A,3516.1459,N,13614.9700,E,73.50,A,125,0*64"
        let results         = measurementData.parseMeasurementData()!
        
        XCTAssertEqual(results["data"] as? String,          measurementData)
        XCTAssertEqual(results["date"] as? NSDate,          NSDate(timeIntervalSince1970: 1365658851))
        XCTAssertEqual(results["deviceId"] as? String,      "0210")
        XCTAssertEqual(results["cpm"] as? Int,              35)
        XCTAssertEqual(results["dataValidity"] as? Bool,    true)
        XCTAssertEqual(results["latitude"] as? Double,      35.26909833333333)
        XCTAssertEqual(results["longitude"] as? Double,     136.2495)
        XCTAssertEqual(results["altitude"] as? Double,      73.5)
        XCTAssertEqual(results["gpsValidity"] as? Bool,     true)
        XCTAssertEqual(results["hdop"] as? Int,             125)
    }
    
    func testParseMeasurementDataInvertedGeolocation() {
        let measurementData = "$BNRDD,0210,2013-04-11T05:40:51Z,35,0,736,A,3516.1459,S,13614.9700,W,73.50,A,125,0*64"
        let results         = measurementData.parseMeasurementData()!
        
        XCTAssertEqual(results["latitude"] as? Double,      -35.26909833333333)
        XCTAssertEqual(results["longitude"] as? Double,     -136.2495)
    }
    
    func testParseMeasurementDataInvalid() {
        XCTAssertNil("NODATA".parseMeasurementData())
        XCTAssertNil("$BNRDD,0210".parseMeasurementData())
    }
}
