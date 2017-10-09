//
//  JSON.swift
//  Friends
//
//  Created by Jussi Suojanen on 04/02/17.
//  Copyright © 2017 Jimmy. All rights reserved.
//

import Foundation

typealias JSON = Dictionary<String, Any>


extension String {
    func convertToJSON() -> JSON{
        if let data = self.data(using: String.Encoding.utf8) {
            
            do {
                if let dictonary: JSON = try JSONSerialization.jsonObject(with: data, options: []) as? JSON {
                    return dictonary
                }
            } catch let error as NSError {
                print(error)
                return [:]
            }
        }
        return [:]
    }
}
