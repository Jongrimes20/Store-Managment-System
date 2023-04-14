//
//  CustomerCreationVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/14/22.
//

import Foundation
import UIKit
import CloudKit



class CustomerCreationVC: UIViewController {
    //IBOutlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmPasswordTF: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional setup
    }
    
    //Create the new customer from the sign up page
    @IBAction func createCustomer(_ sender: Any) {
        //for determining if any info was missed or not acceptable
        var creationError: Bool = false
        
        //check the text fields
        if (nameTF.text == "") {
            creationError = true
            nameTF.text = "Please Enter Your Name"
            nameTF.textColor = .red
        }
        if (emailTF.text == "") {
            creationError = true
            emailTF.text = "Please Enter Your Email"
            emailTF.textColor = .red
        }
        if (passwordTF.text == "") {
            creationError = true
            passwordTF.text = "Please Enter Your Password"
            passwordTF.textColor = .red
        }
        if (confirmPasswordTF.text == "") {
            creationError = true
            confirmPasswordTF.text = "Please Confirm Your Password"
            confirmPasswordTF.textColor = .red
        }
        if (confirmPasswordTF.text != passwordTF.text) {
            creationError = true
            confirmPasswordTF.text = "Please Make Sure Your Passwords Match"
            confirmPasswordTF.textColor = .red
        }
        if (creationError == false) {
            //create the customer
            let cloudDB = CKContainer.default().privateCloudDatabase
            let accZone = CKRecordZone(zoneName: "Account")
            let accZoneID = accZone.zoneID
            
            //create the 'Customer' Record to be saved
            //Specifies that it should go into the "Customers" zone
            let recordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: accZoneID)
            let newCustomer = CKRecord(recordType: "AccountInfo", recordID: recordID)

            
            //will add location in customer settings or when creating their first order
            newCustomer.setValuesForKeys([
                "Name": nameTF.text!,
                "Email": emailTF.text!,
                "Password": passwordTF.text!,
                "StreetAddress": "",
                "ZipCode": "",
                "Country": "",
                "CardInfo": "",
                "DeviceIdentifier": UIDevice.current.identifierForVendor!.uuidString
            ])
            
            let createCustomer = CKModifyRecordsOperation(recordsToSave: [newCustomer], recordIDsToDelete: [])
            createCustomer.savePolicy = .allKeys
            
            cloudDB.add(createCustomer)
            
            //create the User obj to for the user
            user = User(newCustomer)
            
            //Segue to the actual customer system
            performSegue(withIdentifier: "ToCustomerSystem", sender: self)
        }
    }
}
