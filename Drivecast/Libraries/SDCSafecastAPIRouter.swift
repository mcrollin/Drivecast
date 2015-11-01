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
    case ImportLogs(Int, Int)
    case ImportLog(Int)
    case CreateImportLog(String)
    case EditImportLogMetadata(Int, String, String, String, String, String)
    case SubmitImportLog(Int, String)
    
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
        case .ImportLogs:
            return .GET
        case .ImportLog:
            return .GET
        case .CreateImportLog:
            return .POST
        case .EditImportLogMetadata:
            return .PUT
        case .SubmitImportLog:
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
        case .ImportLogs:
            return "/bgeigie_imports.json"
        case .ImportLog(let id):
            return "/bgeigie_imports/\(id).json"
        case .CreateImportLog:
            return "/bgeigie_imports.json"
        case .EditImportLogMetadata(let id, _, _, _, _, _):
            return "/bgeigie_imports/\(id)"
        case .SubmitImportLog(let id, _):
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
        case .ImportLogs(let userId, let page):
            return ["by_user_id": userId, "page": page, "order": "created_at desc"] // OR updated_at
        case .ImportLog:
            return [:]
        case .CreateImportLog:
            return [:]
        case .EditImportLogMetadata(_, let key, let cities, let credits, let name, let description):
            return ["api_key": key, "bgeigie_import[credits]": credits, "bgeigie_import[cities]": cities, "bgeigie_import[name]": name, "bgeigie_import[description]": description]
        case .SubmitImportLog(_, let key):
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
        case .CreateImportLog(let boundaryConstant):
            let contentType = "multipart/form-data; boundary=" + boundaryConstant
            mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
            
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        default:
            return encoding.encode(mutableURLRequest, parameters: parameters).0
        }
    }
}
