//
//  SDCSafecastAPIRouterTests.swift
//  Drivecast
//
//  Created by Marc Rollin on 11/17/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import XCTest

class SDCSafecastAPIRouterTests: XCTestCase {
    
    func testDashboard() {
        let baseURL = SDCConfiguration.API.baseURL
        let route   = SDCSafecastAPIRouter.Dashboard()
        let request = route.URLRequest
        
        XCTAssertEqual(request.URLString, baseURL + "/?")
    }
    
    func testSignIn() {
        let email       = "email@totest.com"
        let password    = "pa$$w0rd"
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.SignIn(email, password)
        let request     = route.URLRequest
        let parameters  = route.parameters
        
        XCTAssertEqual(request.URLString, baseURL + "/users/sign_in")
        XCTAssertEqual(parameters["user[email]"] as? String, email)
        XCTAssertEqual(parameters["user[password]"] as? String, password)
    }
    
    func testSignOut() {
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.SignOut()
        let request     = route.URLRequest
        
        XCTAssertEqual(request.URLString, baseURL + "/logout?")
    }
    
    func testUser() {
        let userId      = 42
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.User(userId)
        let request     = route.URLRequest
        
        XCTAssertEqual(request.URLString, baseURL + "/users/\(userId).json?")
    }
    
    func testImportLogs() {
        let userId      = 42
        let page        = 21
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.ImportLogs(userId, page)
        let request     = route.URLRequest
        
        XCTAssertEqual(request.URLString, baseURL + "/bgeigie_imports.json?by_user_id=\(userId)&order=created_at%20desc&page=\(page)")
    }
    
    func testImportLog() {
        let logId       = 42
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.ImportLog(logId)
        let request     = route.URLRequest
        
        XCTAssertEqual(request.URLString, baseURL + "/bgeigie_imports/\(logId).json?")
    }
    
    func testCreateImportLog() {
        let boundary    = "BOUNDARY42"
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.CreateImportLog(boundary)
        let request     = route.URLRequest
        let contentType = request.allHTTPHeaderFields!["Content-Type"]
        
        XCTAssertEqual(request.URLString, baseURL + "/bgeigie_imports.json")
        XCTAssertEqual(contentType, "multipart/form-data; boundary=\(boundary)")
    }
    
    func testEditImportLogMetadata() {
        let logId       = 42
        let key         = "THISISTHEKEY"
        let cities      = "here, there"
        let credits     = "him, here"
        let name        = "Foobar"
        let description = "Lorem ipsum"
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.EditImportLogMetadata(logId, key, cities, credits, name, description)
        let request     = route.URLRequest
        let parameters  = route.parameters
        
        XCTAssertEqual(request.URLString, baseURL + "/bgeigie_imports/\(logId)")
        XCTAssertEqual(parameters["api_key"] as? String, key)
        XCTAssertEqual(parameters["bgeigie_import[credits]"] as? String, credits)
        XCTAssertEqual(parameters["bgeigie_import[cities]"] as? String, cities)
        XCTAssertEqual(parameters["bgeigie_import[name]"] as? String, name)
        XCTAssertEqual(parameters["bgeigie_import[description]"] as? String, description)
    }
    
    func testSubmitImportLog() {
        let logId       = 42
        let key         = "THISISTHEKEY"
        let baseURL     = SDCConfiguration.API.baseURL
        let route       = SDCSafecastAPIRouter.SubmitImportLog(logId, key)
        let request     = route.URLRequest
        let parameters  = route.parameters
        
        XCTAssertEqual(request.URLString, baseURL + "/bgeigie_imports/\(logId)/submit")
        XCTAssertEqual(parameters["api_key"] as? String, key)
    }
    
}
