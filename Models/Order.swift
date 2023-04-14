//
//  Order.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//  Defines the Order struct

import Foundation
import SQLite
import CloudKit
import UIKit

class Order {
    var ID: Int
    var date: Date
    var customerID: Int
    var item: Int
    var itemPhoto: UIImage
    var quantity: Int
    var shipperID: Int
    var employeeID: Int
    var cloudID: String
    
    init (_ ID: Int, _ date: Date, _ customerID: Int, _ item: Int, _ quantity: Int, _ shipperID: Int) {
        self.ID = ID
        self.date = date
        self.customerID = customerID
        self.item = item
        self.quantity = quantity
        self.shipperID = shipperID
        self.employeeID = Int.random(in: 1...5)
        self.itemPhoto = UIImage()
        self.cloudID = ""
    }
    
    init (record: CKRecord) {
        self.ID = record["orderID"] as! Int
        self.date = record["orderDate"] as! Date
        self.customerID = record["customerID"] as! Int
        self.item = record["Item"] as! Int
        self.itemPhoto = productsArray[item-1].productPhoto
        self.quantity = record["Quantity"] as! Int
        self.shipperID = record["shipperID"] as! Int
        self.employeeID = record["employeeID"] as! Int
        self.cloudID = record.recordID.recordName
    }
    
    func updateValues(record: CKRecord) {
        self.customerID = record["customerID"] as! Int
        self.item = record["Item"] as! Int
        self.itemPhoto = productsArray[item-1].productPhoto
        self.quantity = record["Quantity"] as! Int
        self.shipperID = record["shipperID"] as! Int
        self.employeeID = record["employeeID"] as! Int
    }
    
}
