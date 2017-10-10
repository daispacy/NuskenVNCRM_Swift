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
    case ver = "1.0"
    case act_authentic = "authentic"
    case act_customers = "customers"
    case act_group = "groupcustomers"
    case act_topproduct = "topproduct"
}

protocol SyncServiceDelegate:class {
    func syncService(localService:SyncService,didReceiveData:Any)
    func syncService(localService:SyncService,didFailed:Any)
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
    
    // start service
    func startService() {
        
    }
    
    // MARK: - Accessors
    class func shared() -> SyncService {
        return sharedSyncService
    }
    
    
    typealias GetUserResult = Result<User, GetDataFailureReason>
    typealias GetUserCompletion = (_ result: GetUserResult) -> Void
    
    // MARK: - STATIC INTERFACE
    // MARK: - AUTHENTIC
    func login(email:String?, username:String?, password:String, completion: @escaping GetUserCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_authentic.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
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
    
    // MARK: - CUSTOMER
    
    func getCustomers(page:Int,_ numberItem:Int = 40) {
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_customers.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        parameters["store_id"] = User.currentUser().store_id
        parameters["page"] = page
        parameters["number_item"] = numberItem
        parameters["type"] = "all"
        parameters["distributor_id"] = User.currentUser().id
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        self.delegate_?.syncService(localService: self, didFailed: ["message":"failed_parse_json".localized()])
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let jsonArray:[JSON] = jsonArray["data"] as? [JSON]{
                                self.delegate_?.syncService(localService: self, didReceiveData: jsonArray.flatMap({Customer(json:$0)}))
                            }
                        } else {
                            self.delegate_?.syncService(localService: self, didFailed: ["message":"failed_get_data".localized()])
                        }
                    }
                case .failure(_):
                    self.delegate_?.syncService(localService: self, didFailed: ["message":"failed_get_data".localized()])
                }
        }
    }
    
    // MARK: - group customer
    typealias GetGroupResult = Result<[GroupCustomer], GetDataFailureReason>
    typealias GetGroupCompletion = (_ result: GetGroupResult) -> Void
    func getAllGroup(completion: @escaping GetGroupCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_group.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        parameters["store_id"] = User.currentUser().store_id
        parameters["type"] = "all"
        parameters["distributor_id"] = User.currentUser().id
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        if let reason = GetDataFailureReason(rawValue: 404) {
                            completion(.failure(reason))
                        }
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let jsonArray:[JSON] = jsonArray["data"] as? [JSON]{
                                completion(.success(jsonArray.flatMap({GroupCustomer(json:$0)})))
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let reason = GetDataFailureReason(rawValue: 404) {
                        completion(.failure(reason))
                    }
                }
        }
    }
    
    func postAllGroupToServer(list:[[String:Any]],completion: @escaping GetGroupCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_group.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        parameters["store_id"] = User.currentUser().store_id
        parameters["type"] = "sync"
        parameters["distributor_id"] = User.currentUser().id
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
             parameters["list_group"] = theJSONText
        }
       
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        if let reason = GetDataFailureReason(rawValue: 404) {
                            completion(.failure(reason))
                        }
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let jsonArray:[JSON] = jsonArray["data"] as? [JSON]{
                                completion(.success(jsonArray.flatMap({GroupCustomer(json:$0)})))
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let reason = GetDataFailureReason(rawValue: 404) {
                        completion(.failure(reason))
                    }
                }
        }
    }
}
