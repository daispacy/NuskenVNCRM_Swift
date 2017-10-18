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
    case domain = "https://nuskinvncrm.com/mobile.php"
    case op = "mobile"
    case ver = "1.0"
    case act_authentic = "authentic"
    case act_customers = "customers"
    case act_group = "groupcustomers"
    case act_topproduct = "topproduct"
    case act_config = "config"
}

protocol SyncServiceDelegate:class {
    func syncService(localService:SyncService,didReceiveData:Any)
    func syncService(localService:SyncService,didFailed:Any)
}

final class SyncService: NSObject {
    
    enum GetDataFailureReason: Int, Error {
        case unAuthorized = 401
        case notFound = 404
        case cantParseData = 501
    }
    
    static let shared = SyncService()
    
    private override init() {
        super.init()
    }
    
    // MARK: -
    weak var delegate_:SyncServiceDelegate?
    
    // start service
    func getConfig() {
        let parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_config.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        print("Cant get config from server 0")
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let json:JSON = jsonArray["data"] as? JSON{

                                if let jsonCountry:[JSON] = json["city"] as? [JSON] {
//                                    let listCountry:[City] = jsonCountry.flatMap({City(json:$0)})
                                    UserDefaults.standard.set(NSKeyedArchiver.archivedData(withRootObject:jsonCountry), forKey: "App:ListCity")
                                    UserDefaults.standard.synchronize()
//                                    do {
//                                    try LocalService.shared.db.transaction {
//                                        LocalService.shared.customSQl(sql: "delete from `city`", onComplete: {
//                                            print("start merge CITY to local DB")
//                                            let listCountry:[City] = jsonCountry.flatMap({City(json:$0)})
//                                            _ = listCountry.map({
//                                                LocalService.shared.addCity(obj: $0)
//                                            })
//                                        })
//                                    }
//                                    } catch {
//
//                                    }
                                    
                                }
                                
                                if let deeplink:String = json["zalo_deeplink"] as? String {
                                    print("DEEPLINK ZALO: \(deeplink)")
                                    AppConfig.deeplink.setZalo(str: deeplink)
                                }
                                
                                if let deeplink:String = json["viber_deeplink"] as? String {
                                    print("DEEPLINK VIBER: \(deeplink)")
                                    AppConfig.deeplink.setViber(str: deeplink)
                                }
                                
                                if let deeplink:String = json["skype_deeplink"] as? String {
                                    print("DEEPLINK SKYPE: \(deeplink)")
                                    AppConfig.deeplink.setSkype(str: deeplink)
                                }
                                
                                if let deeplink:String = json["facebook_deeplink"] as? String {
                                    print("DEEPLINK FACEBOOK: \(deeplink)")
                                    AppConfig.deeplink.setFacebook(str: deeplink)
                                }
                                
                                if let deeplink:String = json["facebook_group_deeplink"] as? String {
                                    print("DEEPLINK FACEBOOK GROUP: \(deeplink)")
                                    AppConfig.deeplink.setFacebookGroup(str: deeplink)
                                }
                                
                            }
                        }
                    }
                case .failure(_):
                    print("Cant get config from server 1")
                }
        }
    }
    
    func startService() {
        
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
    typealias GetCustomerResult = Result<[Customer], GetDataFailureReason>
    typealias GetCustomerCompletion = (_ result: GetCustomerResult) -> Void
    func getCustomers(completion: @escaping GetCustomerCompletion) {
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_customers.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        parameters["store_id"] = User.currentUser().store_id
        parameters["page"] = 1
        parameters["number_item"] = 99999
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
                                completion(.success(jsonArray.flatMap({Customer(json:$0)})))
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
    
    func postAllCustomerToServer(list:[[String:Any]],completion: @escaping GetCustomerCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_customers.rawValue)",
            "ver":"\(Server.ver.rawValue)"]
        
        parameters["store_id"] = User.currentUser().store_id
        parameters["type"] = "sync"
        parameters["distributor_id"] = User.currentUser().id
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            parameters["list_customer"] = theJSONText
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
                                completion(.success(jsonArray.flatMap({Customer(json:$0)})))
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
                                     encoding: .utf8)
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
