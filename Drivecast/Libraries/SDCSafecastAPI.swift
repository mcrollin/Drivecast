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

// Handle all Safecast API calls
struct SDCSafecastAPI {
}

// MARK - Import
extension SDCSafecastAPI {
    
    // Error enum
    enum ImportLogError: ErrorType {
        case Network(String)
    }
    
    typealias ResultImportLogs  = SDCSafecastAPIResult<[SDCImportLog]> -> Void
    typealias ResultImportLog   = SDCSafecastAPIResult<SDCImportLog> -> Void
    
    // Retrieves paged list of Import Logs for a User ordered by most recent creation date
    static func retrieveImports(userId: Int, page: Int, completion: ResultImportLogs) {
        let request = SDCSafecastAPIRouter.ImportLogs(userId, page)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    let json    = JSON(json)
                    let array   = json.array!
                    let result: [SDCImportLog] = JSON.collection(array)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.ImportLogError.Network(error.localizedDescription)))
                }
        }
    }
    
    // Retrieves an Import
    static func retrieveImport(importId: Int, completion: ResultImportLog) {
        let request = SDCSafecastAPIRouter.ImportLog(importId)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    let json                    = JSON(json)
                    let result: SDCImportLog    = SDCImportLog.json(json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.ImportLogError.Network(error.localizedDescription)))
                }
        }
    }
    
    private static func sendImportLogRequest(importId: Int, request: URLRequestConvertible, completion: ResultImportLog) {
        let delegate    = Alamofire.Manager.sharedInstance.delegate
        
        // Disable HTTP Redirection
        delegate.taskWillPerformHTTPRedirection = { session, task, response, request in
            return SDCSafecastAPIRouter.ImportLog(importId).URLRequest
        }
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    let json                    = JSON(json)
                    let result: SDCImportLog    = SDCImportLog.json(json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.ImportLogError.Network(error.localizedDescription)))
                }
        }
    }
    
    // Edit an import log's metadata (cities and credits)
    static func editImportLogMetadata(importId: Int, key: String, cities: String, credits: String, name: String, description: String, completion: SDCSafecastAPI.ResultImportLog) {
        let request = SDCSafecastAPIRouter.EditImportLogMetadata(importId, key, cities, credits, name, description)
        
        sendImportLogRequest(importId, request: request, completion: completion)
    }
    
    // Submits an import log for approval
    static func submitImportLog(importId: Int, key: String, completion: ResultImportLog) {
        let request = SDCSafecastAPIRouter.SubmitImportLog(importId, key)
        
        sendImportLogRequest(importId, request: request, completion: completion)
    }
    
    // Create a new import log
    static func createImportLog(data: NSData, boundaryConstant: String, completion: ResultImportLog) {
        let request = SDCSafecastAPIRouter.CreateImportLog(boundaryConstant)
        
        Alamofire.upload(request, data: data)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    let json                    = JSON(json)
                    let result: SDCImportLog    = SDCImportLog.json(json)
                    
                    completion(.Success(result))
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.ImportLogError.Network(error.localizedDescription)))
                }
        }
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
    static func retrieveUser(id: Int, email: String, key: String?, completion: ResultUser) {
        let request = SDCSafecastAPIRouter.User(id)
        
        Alamofire.request(request)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    var json    = JSON(json)

                    // Preserve key persistence
                    if let key = key {
                        json["authentication_token"] = JSON(key)
                    }
                    
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
                    
                    retrieveUser(id, email: email, key: nil, completion: completion)
                    
                case .Failure(let error):
                    completion(.Failure(SDCSafecastAPI.UserError.Network(error.localizedDescription)))
                }
        }
    }
    
    // Signin in
    static func signInUser(email: String, password: String, completion: ResultUser) {
        // Trim the email from any whitespace character
        let email   = email.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
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