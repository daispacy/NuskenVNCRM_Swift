//
//  ProductDO+CoreDataClass.swift
//  NuskinVN CRM
//
//  Created by Dai Pham on 10/22/17.
//  Copyright © 2017 Dai Pham. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ProductDO)
public class ProductDO: NSManagedObject {
    //MARK: - Initialize
    convenience init(needSave: Bool,  context: NSManagedObjectContext?) {
        
        // Create the NSEntityDescription
        let entity = NSEntityDescription.entity(forEntityName: "ProductDO", in: context!)
        
        if(!needSave) {
            self.init(entity: entity!, insertInto: nil)
        } else {
            self.init(entity: entity!, insertInto: context)
        }
    }
}
