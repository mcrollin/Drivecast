//
//  SDCSafecastAPI.swift
//  Drivecast
//
//  Created by Marc Rollin on 10/14/15.
//  Copyright © 2015 Safecast. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

enum SDCSafecastAPIResult<T> {
    case Success(T)
    case Failure(ErrorType)
}

/**
    Struct handling all Safecast API calls.
*/
struct SDCSafecastAPI {
}

// MARK - Import
extension SDCSafecastAPI {
    
    typealias SDCSafecastAPIResultImports   = SDCSafecastAPIResult<[SDCImport]> -> Void
    typealias SDCSafecastAPIResultImport    = SDCSafecastAPIResult<SDCImport> -> Void
    
    // Retrieves paged list of Imports for a User ordered by most recent creation date
    static func retrieveImports(userId: Int, page: Int, completion: SDCSafecastAPIResultImports) {
        let request = SDCSafecastAPIRouter.Imports(userId, page)
        
        Alamofire.request(request)
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    let json    = JSON(json)
                    let array   = json.array!
                    let result: [SDCImport] = JSON.collection(array)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    
    private static func sendImportRequest(importId: Int, request: URLRequestConvertible, completion: SDCSafecastAPIResultImport) {
        let delegate    = Alamofire.Manager.sharedInstance.delegate
        
        // Disable HTTP Redirection
        delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            return SDCSafecastAPIRouter.Import(importId).URLRequest
        }
        
        Alamofire.request(request)
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    log("RESULT \(json)")
                    let json    = JSON(json)
                    let result: SDCImport = SDCImport(json: json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    
    // Edit an import's metadata (cities and credits)
    static func editImportMetadata(importId: Int, key: String, cities: String, credits: String, completion: SDCSafecastAPIResultImport) {
        let request = SDCSafecastAPIRouter.EditImportMetadata(importId, key, cities, credits)
        
        sendImportRequest(importId, request: request, completion: completion)
    }
    
    // Submits an import for approval
    static func submitImport(importId: Int, key: String, completion: SDCSafecastAPIResultImport) {
        let request = SDCSafecastAPIRouter.SubmitImport(importId, key)
        
        sendImportRequest(importId, request: request, completion: completion)
    }
}

// MARK - User
extension SDCSafecastAPI {
    // Error enum
    enum UserError: ErrorType {
        case CouldNotFoundAPIKey(String)
        case CouldNotFoundId(String)
    }
    
    typealias SDCSafecastAPIResultUser = SDCSafecastAPIResult<SDCUser> -> Void
    
    // Retrieving the user
    static func retrieveUser(id: Int, email: String, completion: SDCSafecastAPIResultUser) {
        let request = SDCSafecastAPIRouter.User(id)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    log("RESULT \(json)")
                    var json    = JSON(json)
                    
                    // Adding the email to the json data
                    json["email"] = JSON(email)
                    
                    let result: SDCUser = SDCUser(json: json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    
    // Retrieving the user's id
    private static func retrieveUserId(email: String, completion: SDCSafecastAPIResultUser) {
        let request = SDCSafecastAPIRouter.Dashboard()
        
        Alamofire.request(request)
            .validate()
            .responseString { response in
                switch response.result {
                case .Success(let string):
                    guard let id = Int(string.regexpFind("id=\"edit_user_([0-9]*)\"")!) else {
                        return completion(.Failure(SDCSafecastAPI.UserError.CouldNotFoundId(string)))
                    }
                    
                    retrieveUser(id, email: email, completion: completion)
                    
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
    
    // Signin in
    static func signInUser(email: String, password: String, completion: SDCSafecastAPIResultUser) {
        // Trim the email from any whitespace character
        let email = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
        let request = SDCSafecastAPIRouter.SignIn(email, password)
        
        Alamofire.request(request)
            .validate()
            .responseString { response in
                switch response.result {
                case .Success(let string):
                    guard let _ = string.regexpFind("(Retrieve your API key)") else {
                        return completion(.Failure(SDCSafecastAPI.UserError.CouldNotFoundAPIKey(string)))
                    }
                    
                    retrieveUserId(email, completion: completion)
                    
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
}