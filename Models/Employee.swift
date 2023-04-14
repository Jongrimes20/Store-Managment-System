//
//  Employee.swift
//  Store Managment System
//
//  Created by Jon Grimes on 3/30/22.
//

import Foundation
import CloudKit

struct Employee {
    var ID: Int
    var Name: String
    var DOB: String
    var Notes: String
    var imgName: String
    
    init (record: CKRecord) {
        self.ID = record["employeeID"] as! Int
        self.Name = record["employeeName"] as! String
        self.DOB = record["birthDate"] as! String
        self.Notes = record["notes"] as! String
        self.imgName = record["PhotoName"] as! String
    }
}
