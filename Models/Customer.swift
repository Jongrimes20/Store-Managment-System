//
//  Customer.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//  Defines the customer struct

import Foundation
import SQLite
import CloudKit

class Customer {
    var ID: Int
    var CustomerName: String
    var ContactName: String
    var Address: String
    var City: String
    var PostalCode: String
    var Country: String
    var cloudID: String
    
    //Initializer
    init (_ ID: Int, _ name: String, _ ContactName: String, _ address: String, _ city: String, _ postalCode: String, _ country: String) {
        self.ID = ID
        self.CustomerName = name
        self.ContactName = ContactName
        self.Address = address
        self.City = city
        self.PostalCode = postalCode
        self.Country = country
        self.cloudID = ""
    }
    
    //Initializer with CKRecord
    init (record: CKRecord) {
        self.ID = record["customerID"] as! Int
        self.CustomerName = record["customerName"] as! String
        self.ContactName = record["contactName"] as! String
        self.Address = record["Address"] as! String
        self.City = record["City"] as! String
        self.PostalCode = record["postCode"] as! String
        self.Country = record["Country"] as! String
        self.cloudID = record.recordID.recordName
    }
    
    func updateValues(record: CKRecord) {
        self.CustomerName = record["customerName"] as! String
        self.ContactName = record["contactName"] as! String
        self.Address = record["Address"] as! String
        self.City = record["City"] as! String
        self.PostalCode = record["postCode"] as! String
        self.Country = record["Country"] as! String
    }
}
