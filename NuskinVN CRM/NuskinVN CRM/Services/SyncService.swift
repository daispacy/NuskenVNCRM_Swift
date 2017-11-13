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
    case ver = "1.2"
    case act_authentic = "authentic"
    case act_resetpw = "resetpw"
    case act_customers = "customers"
    case act_group = "groupcustomers"
    case act_product = "product"
    case act_productgroup = "allgroup&product"
    case act_config = "config"
    case act_dashboard = "dashboard"
    case act_order = "order"
    case act_user = "user"
    case act_master_data = "master_data"
    case act_email = "email"
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
        case invalid = 0
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
                                
                                if let deeplink:String = json["facebook_link_itunes"] as? String {
                                    print("LINK FACEBOOK ITUNES: \(deeplink)")
                                    AppConfig.deeplink.setFacebookLinkItunes(str: deeplink)
                                }
                                
                                if let deeplink:String = json["zalo_link_itunes"] as? String {
                                    print("LINK ZALO ITUNES: \(deeplink)")
                                    AppConfig.deeplink.setZaloLinkItunes(str: deeplink)
                                }
                                
                                if let deeplink:String = json["viber_link_itunes"] as? String {
                                    print("LINK VIBER ITUNES: \(deeplink)")
                                    AppConfig.deeplink.setViberLinkItunes(str: deeplink)
                                }
                                
                                if let deeplink:String = json["skype_link_itunes"] as? String {
                                    print("LINK SKYPE ITUNES: \(deeplink)")
                                    AppConfig.deeplink.setSkypeLinkItunes(str: deeplink)
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
                                let container = CoreDataStack.sharedInstance.persistentContainer
                                container.performBackgroundTask() { (context) in
                                    let user:UserDO = UserManager.saveUserWith(dictionary: json,context)!
                                    do {
                                        try context.save()
                                        if user.status == 0 {
                                            if let reason = GetDataFailureReason(rawValue: 0) {
                                                completion(.failure(reason))
                                            }
                                        } else {
                                            completion(.success(user))
                                        }
                                    } catch {
                                        if let reason = GetDataFailureReason(rawValue: 0) {
                                            completion(.failure(reason))
                                        }
                                    }
                                }
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: (jsonArray["code"] as? Int) ?? 530) {
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
    
    func changePW(current:String, newPW:String, retypePW:String, onDone:(()->Void)?, onFail:((String)->Void)?) {
        guard let user = UserManager.currentUser() else { return}
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_user.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)",
            "type":"changepw"]
        
        parameters["username"] = user.username
        parameters["current_password"] = current
        parameters["new_password"] = newPW
        parameters["confirm_password"] = retypePW
        
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
                                onFail?(msg.localized())
                            } else {
                                onFail?("")
                            }
                        }
                    }
                case .failure(_):
                    onFail?("")
                }
        }
    }
    
    func syncUser(_ completion: @escaping GetUserCompletion) {
        guard let user = UserManager.currentUser() else { return}
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_user.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
        parameters["store_id"] = user.store_id
        parameters["distributor_id"] = user.id
        
        if let data = user.address {
            parameters["address"] = data
        }
        
        if let data = user.email {
            parameters["email"] = data
        }
        
        if let data = user.fullname {
            parameters["fullname"] = data
        }
        
        if let data = user.tel {
            parameters["tel"] = data
        }
        
        if let data = user.avatar {
            parameters["avatar"] = data
        }
        
        if let data = user.device_token {
            parameters["device_token"] = data
        }
        
        if !user.synced {
            parameters["type"] = "sync"
        } else {
            parameters["type"] = "update"
        }
        
        parameters["device"] = "IOS"
        
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
                                if let bool = LocalService.shared.isShouldSyncData?() {
                                    if bool == false {
                                        print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                                        if let reason = GetDataFailureReason(rawValue: (jsonArray["code"] as? Int) ?? 530) {
                                            completion(.failure(reason))
                                        }
                                        return
                                    }
                                }
                                let container = CoreDataStack.sharedInstance.persistentContainer
                                container.performBackgroundTask() { (context) in
                                    let user:UserDO = UserManager.saveUserWith(dictionary: json,context)!
                                    do {
                                        try context.save()
                                        if user.status == 0 {
                                            if let reason = GetDataFailureReason(rawValue: 0) {
                                                completion(.failure(reason))
                                            }
                                        } else {
                                            completion(.success(user))
                                        }
                                    } catch {
                                        if let reason = GetDataFailureReason(rawValue: 0) {
                                            completion(.failure(reason))
                                        }
                                        fatalError("Failure to save context: \(error)")
                                    }
                                }
                                
                            }
                        } else {
                            if let reason = GetDataFailureReason(rawValue: (jsonArray["code"] as? Int) ?? 530) {
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
        parameters["distributor_id"] = user.id
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        parameters["distributor_id"] = user.id
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            parameters["list_customer"] = theJSONText
        }
        
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        parameters["distributor_id"] = user.id
        
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        parameters["distributor_id"] = user.id
        
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
             parameters["list_group"] = theJSONText
        }
       
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        parameters["distributor_id"] = user.id
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: list,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .utf8)
            parameters["list_items"] = theJSONText
        }
        
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
        parameters["distributor_id"] = user.id
        
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
        parameters["distributor_id"] = user.id
        
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
    
    // MARK: - Product & Group Product
    typealias GetProductResult = Result<JSON, GetDataFailureReason>
    typealias GetProductCompletion = (_ result: GetProductResult) -> Void
    func syncProducts(_ completion: @escaping GetProductCompletion) {
        guard let user = UserManager.currentUser() else { return}
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_product.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
        parameters["store_id"] = user.store_id
        parameters["type"] = "allgroup&product"
        
        if let updated = user.last_login as Date?{
            parameters["from_date"] = updated.toString(dateFormat: "yyyy-MM-dd HH:mm:ss")
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
                    if let bool = LocalService.shared.isShouldSyncData?() {
                        if bool == false {
                            if let reason = GetDataFailureReason(rawValue: 404) {
                                completion(.failure(reason))
                            }
                            print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                            NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                            NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                            return
                        }
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            if let json:JSON = jsonArray["data"] as? JSON{
                                if let jsonGroup:[JSON] = json["products"] as? [JSON]{
                                    ProductManager.saveProducctWith(array: jsonGroup) {
                                        if let jsonGroup:[JSON] = json["groups"] as? [JSON]{
                                            ProductManager.saveGroupWith(array: jsonGroup) {
                                                completion(.success(json))
                                            }
                                        } else {
                                            if let reason = GetDataFailureReason(rawValue: 404) {
                                                completion(.failure(reason))
                                            }
                                        }
                                    }
                                } else {
                                    if let reason = GetDataFailureReason(rawValue: 404) {
                                        completion(.failure(reason))
                                    }
                                }
                            } else {
                                if let reason = GetDataFailureReason(rawValue: 404) {
                                    completion(.failure(reason))
                                }
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
    
    // MARK: - Master Data
    func getMasterData(completion: @escaping GetGroupCompletion) {
        
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10 // seconds
        configuration.timeoutIntervalForResource = 10
        _ = Alamofire.SessionManager(configuration: configuration)
        
        let parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_master_data.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
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
                            if let jsonArray:[JSON] = jsonArray["data"] as? [JSON] {
                                if let bool = LocalService.shared.isShouldSyncData?() {
                                    if bool == false {
                                        if let reason = GetDataFailureReason(rawValue: 404) {
                                            completion(.failure(reason))
                                        }
                                        print("APP IN STATE BUSY, SO WILL SYNCED LATER")
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:APPBUSY"),object:nil)
                                        NotificationCenter.default.post(name:Notification.Name("SyncData:FOREOUTSYNC"),object:nil)
                                        return
                                    }
                                }
                                print("SAVE MASTER DATA TO CORE DATA")
                                MasterDataManager.saveDataWith(jsonArray) {
                                    completion(.success(jsonArray))
                                }
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
                        completion(.failure(reason))
                    }
                }
        }
    }
    
    // MARK: - Other
    func sendEmail(fullname:String?, from:String?, to:String?, subject:String?, body:String?, attachs:[String]? = nil, completion: @escaping ((NSString)->Void)) {
        
        var parameters: Parameters = ["op":"\(Server.op.rawValue)",
            "act":"\(Server.act_email.rawValue)",
            "ver":"\(Server.ver.rawValue)",
            "app_key":"\(Server.app_key.rawValue)"]
        
        if let user = fullname {
            parameters["fullname"] = user
        }
        
        if let em = from {
            parameters["from"] = em
        }
        
        if let em = to {
            parameters["to"] = em
        }
        
        if let em = subject {
            parameters["subject"] = em
        }
        
        if let em = body {
            parameters["body"] = em
        }
        
        if let attach = attachs {
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: attach,
                options: []) {
                let theJSONText = String(data: theJSONData,
                                         encoding: .utf8)
                parameters["attachs"] = theJSONText
            }
        }
        
        Alamofire.request("\(Server.domain.rawValue)", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: [:])
            .responseString { response in
                switch response.result {
                case .success:
                    
                    guard let jsonArray = response.result.value?.convertToJSON() else {
                        completion("error")
                        return
                    }
                    if let error = jsonArray["error"] as? Int{
                        if error == 0 {
                            completion("")
                        } else {
                            completion("error")
                        }
                    }
                case .failure(_):
                    completion("error")
                }
        }
    }
}
