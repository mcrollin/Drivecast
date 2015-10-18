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
    // Error enum
    enum ImportError: ErrorType {
        case Network(String)
    }
    
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
                    completion(.Failure(SDCSafecastAPI.ImportError.Network(error.localizedDescription)))
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
                    completion(.Failure(SDCSafecastAPI.ImportError.Network(error.localizedDescription)))
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
        case APIKeyCouldNotBeFound(String)
        case UserIdCouldNotBeFound(String)
        case Network(String)
    }
    
    typealias ResultUser = SDCSafecastAPIResult<SDCUser> -> Void
    
    // Retrieving the user
    static func retrieveUser(id: Int, email: String, completion: ResultUser) {
        let request = SDCSafecastAPIRouter.User(id)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    var json    = JSON(json)
                    
                    // Adding the email to the json data
                    json["email"] = JSON(email)
                    
                    let result: SDCUser = SDCUser(json: json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.UserError.Network(error.localizedDescription)))
                }
        }
    }
    
    // Retrieving the user's id
    private static func retrieveUserId(email: String, completion: ResultUser) {
        let request = SDCSafecastAPIRouter.Dashboard()
        
        Alamofire.request(request)
            .validate()
            .responseString { response in
                switch response.result {
                case .Success(let string):
                    guard let id = Int(string.regexpFind("id=\"edit_user_([0-9]*)\"")!) else {
                        return completion(.Failure(SDCSafecastAPI.UserError.UserIdCouldNotBeFound(string)))
                    }
                    
                    retrieveUser(id, email: email, completion: completion)
                    
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.UserError.Network(error.localizedDescription)))
                }
        }
    }
    
    // Signin in
    static func signInUser(email: String, password: String, completion: ResultUser) {
        // Trim the email from any whitespace character
        let email = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    
        let request = SDCSafecastAPIRouter.SignIn(email, password)
        
        Alamofire.request(request)
            .validate()
            .responseString { response in
                switch response.result {
                case .Success(let string):
                    guard let _ = string.regexpFind("(Retrieve your API key)") else {
                        // Retrieve the error message
                        guard let message = string.regexpFind("\"alert\">&times;</button>([^<]*)") else {
                            log(string)
                            
                            return completion(.Failure(SDCSafecastAPI.UserError.APIKeyCouldNotBeFound("Something wrong happened, please try again later.")))
                        }
                        
                        // Trimming white spaces and return characters from the error message
                        let trimmedMessage = message.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
                        
                        return completion(.Failure(SDCSafecastAPI.UserError.APIKeyCouldNotBeFound(trimmedMessage)))
                    }
                    
                    retrieveUserId(email, completion: completion)
                    
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.UserError.Network(error.localizedDescription)))
                }
        }
    }
}