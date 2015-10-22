//
//  SDCSafecastAPIRouter.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import Alamofire

// Configuration needed to build Safecast API call requests
enum SDCSafecastAPIRouter: URLRequestConvertible {
    
    static let baseURLString = SDCConfiguration.API.baseURL
    
    // Endpoints
    case Dashboard()
    case SignIn(String, String)
    case SignOut()
    case User(Int)
    case Imports(Int, Int)
    case Import(Int)
    case CreateImport(String)
    case EditImportMetadata(Int, String, String, String)
    case SubmitImport(Int, String)
    
    // HTTP method
    var method: Alamofire.Method {
        switch self {
        case .Dashboard:
            return .GET
        case .SignIn:
            return .POST
        case .SignOut:
            return .GET
        case .User:
            return .GET
        case .Imports:
            return .GET
        case .Import:
            return .GET
        case .CreateImport:
            return .POST
        case .EditImportMetadata:
            return .PUT
        case .SubmitImport:
            return .PUT
        }
    }
    
    // Resource path
    var path: String {
        switch self {
        case .Dashboard:
            return ""
        case .SignIn:
            return "/users/sign_in"
        case .SignOut:
            return "/logout"
        case .User(let id):
            return "/users/\(id).json"
        case .Imports:
            return "/bgeigie_imports.json"
        case .Import(let id):
            return "/bgeigie_imports/\(id).json"
        case .CreateImport:
            return "/bgeigie_imports.json"
        case .EditImportMetadata(let id, _, _, _):
            return "/bgeigie_imports/\(id)"
        case .SubmitImport(let id, _):
            return "/bgeigie_imports/\(id)/submit"
        }
    }
    
    // Optional parameters
    var parameters: [String: AnyObject] {
        switch self {
        case .Dashboard:
            return [:]
        case .SignIn(let email, let password):
            return ["user[email]": email, "user[password]": password]
        case .SignOut:
            return [:]
        case .User:
            return [:]
        case .Imports(let userId, let page):
            return ["by_user_id": userId, "page": page, "order": "created_at desc"] // OR updated_at
        case .Import:
            return [:]
        case .CreateImport:
            return [:]
        case .EditImportMetadata(_, let key, let credits, let cities):
            return ["api_key": key, "bgeigie_import[credits]": credits, "bgeigie_import[cities]": cities]
        case .SubmitImport(_, let key):
            return ["api_key": key]
        }
    }
    
    // Generated URL request using all previous configurations
    var URLRequest: NSMutableURLRequest {
        let mutableURLRequest:NSMutableURLRequest!
        let URL = NSURL(string: SDCSafecastAPIRouter.baseURLString)!
        let encoding = Alamofire.ParameterEncoding.URL
        mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        mutableURLRequest.HTTPMethod = method.rawValue
        
        switch self {
        case .CreateImport(let boundaryConstant):
            let contentType = "multipart/form-data; boundary=" + boundaryConstant
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        default:
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        }
    }
}
