//
//  User.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import Foundation
import CloudKit

class User {
    var name: String
    var email: String
    var password: String
    var address: String
    var zipCode: String
    var country: String
    var cardInfo: String
    var deviceIdentifier: String
    var cloudID: String
    
    
    init (_ record: CKRecord) {
        self.name = record["Name"] as! String
        self.email = record["Email"] as! String
        self.password = record["Password"] as! String
        self.address = record["StreetAddress"] as! String
        self.zipCode = record["ZipCode"] as! String
        self.country = record["Country"] as! String
        self.cardInfo = record["CardInfo"] as! String
        self.deviceIdentifier = record["DeviceIdentifier"] as! String
        self.cloudID = record.recordID.recordName
    }
    
    init () {
        self.name = ""
        self.email = ""
        self.password = ""
        self.address = ""
        self.zipCode = ""
        self.country = ""
        self.cardInfo = ""
        self.deviceIdentifier = ""
        self.cloudID = ""
    }
    
    func updateValues(record: CKRecord) {
        self.name = record["Name"] as! String
        self.email = record["Email"] as! String
        self.address = record["StreetAddress"] as! String
        self.zipCode = record["ZipCode"] as! String
        self.country = record["Country"] as! String
        self.cardInfo = record["CardInfo"] as! String
    }
    
    func updatePassword(record: CKRecord) {
        self.password = record["Password"] as! String
    }
}
