//
//  SDCMeasurementColorLUTTests.swift
//  Drivecast
//
//  Created by Marc Rollin on 11/17/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import XCTest

class SDCMeasurementColorLUTTests: XCTestCase {
    var lut: SDCMeasurementColorLUT!
    
    override func setUp() {
        super.setUp()
        
        lut = SDCMeasurementColorLUT()
    }
    
    func testIndexForValue() {
        let index       = lut.indexForValue(42)
        let upperBound  = lut.indexForValue(4242424242424242)
        let lesserBound = lut.indexForValue(-42)
        
        XCTAssertEqual(index, 56)
        XCTAssertEqual(upperBound, 254)
        XCTAssertEqual(lesserBound, 0)
    }
    
    func testColorForIndex() {
        let color           = lut.colorForIndex(56)
        let expectedColor   = UIColor(red: 54.0 / 255.0, green: 94.0 / 255.0, blue: 1.0, alpha: 1.0)

        XCTAssertTrue(expectedColor.isEqual(color))
    }
    
    func testColorForValue() {
        let color           = lut.colorForValue(42)
        let expectedColor   = UIColor(red: 54.0 / 255.0, green: 94.0 / 255.0, blue: 1.0, alpha: 1.0)
        
        XCTAssertTrue(expectedColor.isEqual(color))
    }
    
}
