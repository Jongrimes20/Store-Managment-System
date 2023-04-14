//
//  CustomerOrder.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/18/22.
//

import Foundation
import CloudKit

class CustomerOrder {
    var products: [Product]
    var quantities: [Int]
    var datePlaced: String
    var trackingNum: String
    var orderTotal: Double
    var orderTax: Double
    var subTotal: Double
    
    //To initialize a new order before any values are set
    init () {
        self.products = []
        self.quantities = []
        self.datePlaced = ""
        self.orderTotal = 0.0
        self.orderTax = 0.0
        self.subTotal = 0.0
        self.trackingNum = ""
    }
    
    //For initalizing with a CKRecord
    init (record: CKRecord) {
        let prodIDs = record["products"] as! [Int]
        self.products = []
        for prod in prodIDs {
            //adjust the ID to array indexing
            let product = productsArray[prod - 1]
            self.products.append(product)
        }
        
        self.quantities = record["quantities"] as! [Int]
        //configure date as string
        let datePlaced = record["datePlaced"] as! Date
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy"
        self.datePlaced = dateFormat.string(from: datePlaced)
        
        self.trackingNum = record.recordID.recordName
        
        //calculating total, tax, and subtotal
        let total = record["orderTotal"] as! Double
        self.orderTotal = total.rounded(to: 2)
        self.orderTax = (self.orderTotal * 0.0825).rounded(to: 2)
        self.subTotal = (self.orderTotal + self.orderTax).rounded(to: 2)
    }
    
    func updateTotal(newPreTaxPrice: Double) {
        self.orderTotal = newPreTaxPrice.rounded(to: 2)
        self.orderTax = (self.orderTotal * 0.0825).rounded(to: 2)
        self.subTotal = self.orderTotal + self.orderTax
    }
}
