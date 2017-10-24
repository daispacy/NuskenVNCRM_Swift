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
    case app_key = "D3raCMSver30"
    case domain = "https://nuskinvncrm.com/mobile.php"
    case domainImage = "https://nuskinvncrm.com"
    case op = "mobile"
    case ver = "1.0"
    case act_authentic = "authentic"
    case act_resetpw = "resetpw"
    case act_customers = "customers"
    case act_group = "groupcustomers"
    case act_product = "product"
    case act_config = "config"
    case act_dashboard = "dashboard"
    case act_order = "order"
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
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
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
    
    typealias GetUserResult = Result<UserDO, GetDataFailureReason>
    typealias GetUserCompletion = (_ result: GetUserResult) -> Void
    
    // MARK: - STATIC INTERFACE
    // MARK: - AUTHENTIC
    func login(email:String?, username:String?, password:String, completion: @escaping GetUserCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_authentic.rawValue)",
            "ver":"\(Server.ver.rawValue)",
        "app_key":"\(Server.app_key.rawValue)"]
        
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
                                if let user:UserDO = UserManager.saveUserWith(dictionary: json) {
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
    
    func reset(email:String, username:String, onDone:(()->Void)?, onFail:((String)->Void)?) {
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_resetpw.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
            parameters["username"] = username
            parameters["email"] = email
        
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        onFail?("")
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            onDone?()
                        } else {
                            if let msg:String = jsonArray["message"] as? String{
                                onFail?(msg)
                            }
                        }
                    }
                case .failure(_):
                    onFail?("")
                }
        }
    }
    
    // MARK: - CUSTOMER
    typealias GetCustomerDOResult = Result<[JSON], GetDataFailureReason>
    typealias GetCustomerDOCompletion = (_ result: GetCustomerDOResult) -> Void
    func getAllCustomers(completion: @escaping GetCustomerDOCompletion) {
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_customers.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["page"] = 1
        parameters["number_item"] = 99999
        parameters["type"] = "all"
        parameters["distributor_id"] = user.id_card_no
        
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
                                completion(.success(jsonArray))
                            } else {
                                completion(.success([]))
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
    
    func postAllCustomerToServer(list:[[String:Any]],completion: @escaping GetCustomerDOCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_customers.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["type"] = "sync"
        parameters["distributor_id"] = user.id_card_no
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
                                completion(.success(jsonArray))
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
    typealias GetGroupResult = Result<[JSON], GetDataFailureReason>
    typealias GetGroupCompletion = (_ result: GetGroupResult) -> Void
    func getAllGroup(completion: @escaping GetGroupCompletion) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_group.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["type"] = "all"
        parameters["distributor_id"] = user.id_card_no
        
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
                                completion(.success(jsonArray))
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
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        _ = Alamofire.SessionManager(configuration: configuration)
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_group.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["type"] = "sync"
        parameters["distributor_id"] = user.id_card_no
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
                                completion(.success(jsonArray))
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let reason = GetDataFailureReason(rawValue: 404) {
                        print("\(reason)")
//                        completion(.failure(reason))
                    }
                }
        }
    }
    
    // MARK: - ORDER
    func postAllOrdersToServer(list:[[String:Any]],completion: @escaping GetGroupCompletion) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        _ = Alamofire.SessionManager(configuration: configuration)
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_order.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["type"] = "sync"
        parameters["distributor_id"] = user.id_card_no
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            parameters["list_items"] = theJSONText
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
                                completion(.success(jsonArray))
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let reason = GetDataFailureReason(rawValue: 404) {
                        print("\(reason)")
                        //                        completion(.failure(reason))
                    }
                }
        }
    }
    
    func getOrderItems(completion: @escaping GetGroupCompletion) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        _ = Alamofire.SessionManager(configuration: configuration)
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_order.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        guard let user = UserManager.currentUser() else { return}
        parameters["store_id"] = user.store_id
        parameters["type"] = "getorderitems"
        parameters["distributor_id"] = user.id_card_no
        
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
                                completion(.success(jsonArray))
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                        }
                    }
                case .failure(_):
                    if let reason = GetDataFailureReason(rawValue: 404) {
                        print("\(reason)")
                        //                        completion(.failure(reason))
                    }
                }
        }
    }
    
    // MARK: - Dashboard
    typealias GetDashboardResult = Result<JSON, GetDataFailureReason>
    typealias GetDashboardCompletion = (_ result: GetDashboardResult) -> Void
    func getDashboard(completion: @escaping GetDashboardCompletion) {
        guard let user = UserManager.currentUser() else { return }
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_dashboard.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
        parameters["store_id"] = user.store_id
        parameters["type"] = "all"
        parameters["distributor_id"] = user.id_card_no
        
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
                            if let jsonArray:JSON = jsonArray["data"] as? JSON{
                                completion(.success(jsonArray))
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
    
    // MARK: - Product
    typealias GetProductResult = Result<[JSON], GetDataFailureReason>
    typealias GetProductCompletion = (_ result: GetProductResult) -> Void
    func syncProducts(completion: @escaping GetProductCompletion) {
        guard let user = UserManager.currentUser() else { return}
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_product.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
        parameters["store_id"] = user.store_id
        parameters["type"] = "all"
        
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
                                ProductManager.saveProducctWith(array: jsonArray)
                                completion(.success(jsonArray))
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
