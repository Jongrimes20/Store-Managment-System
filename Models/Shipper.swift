//
//  Shipper.swift
//  Store Managment System
//
//  Created by Jon Grimes on 3/30/22.
//

import Foundation
import CloudKit

struct Shipper {
    var ID: Int
    var Name: String
    var phoneNumber: String
    
    init (record: CKRecord) {
        self.ID = record["shipperID"] as! Int
        self.Name = record["shipperName"] as! String
        self.phoneNumber = record["phoneNumber"] as! String
    }
}
