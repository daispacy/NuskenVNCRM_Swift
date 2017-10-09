//
//  SyncService.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/9/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//

import UIKit
import Alamofire

enum Server:String {
    case domain = "https://nscrm.derasoft.com/mobile.php"
    case op = "mobile"
    case act_authentic = "authentic"
}

protocol SyncServiceDelegate:class {
    func localService(localService:SyncService,didReceiveData:Any)
    func localService(localService:SyncService,didFailed:Any)
}

class SyncService: NSObject {
    
    enum GetDataFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
        case cantParseData = 501
    }
    
    private static var sharedSyncService: SyncService = {
        let networkManager = SyncService()
        return networkManager
    }()
    
    override init() {
        super.init()
    }
    
    // MARK: -
    weak var delegate_:SyncServiceDelegate?
    var onDone:((Any)->Void)?
    var onFail:((Any)->Void)?
    
    // MARK: - Accessors
    class func shared() -> SyncService {
        return sharedSyncService
    }
    
    
    typealias GetUserResult = Result<User, GetDataFailureReason>
    typealias GetUserCompletion = (_ result: GetUserResult) -> Void
    
    // MARK: - STATIC INTERFACE
    func login(email:String?, username:String?, password:String, completion: @escaping GetUserCompletion) {
        
        var parameters: Parameters = ["op":"mobile",
                                      "act":"authentic"]
        if let user = username {
            parameters["username"] = user
        }
        
        if let em = email {
            parameters["email"] = em
        }
        parameters["password"] = password
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        completion(.failure(GetDataFailureReason(rawValue: 504)))
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let json:JSON = jsonArray["data"] as? JSON{
                                if let user:User = User(json:json) {
                                    User.setCurrentUser(user: json)
                                    completion(.success(user))
                                }
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let statusCode = response.response?.statusCode,
                        let reason = GetDataFailureReason(rawValue: statusCode) {
                        completion(.failure(reason))
                    }
                    completion(.failure(nil))
                }
        }
    }
    
    func reset(email:String, username:String, onDone:((Any)->Void)?, onFail:((Any)->Void)?) {
        
    }
}
