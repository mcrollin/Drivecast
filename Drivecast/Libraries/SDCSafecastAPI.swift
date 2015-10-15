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

    // Retrieves paged list of Imports for a User ordered by most recent creation date
    static func retrieveImports(userId: Int, page: Int, completion: SDCSafecastAPIResult<[SDCImport]> -> Void) {
        let request = SDCSafecastAPIRouter.Imports(userId, page)
        
        Alamofire.request(request)
            .responseJSON { response in
                switch response.result {
                case .Success(let json):
                    do {
                        let json    = JSON(json)
                        let array   = json.array!
                        let result: [SDCImport] = try JSON.collection(array)
                        
                        completion(.Success(result))
                    } catch {
                        completion(.Failure(error))
                    }
                case .Failure(let error):
                    completion(.Failure(error))
                }
        }
    }
}