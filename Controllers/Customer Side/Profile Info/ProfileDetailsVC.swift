//
//  ProfileDetailsVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import Foundation
import UIKit
import CloudKit

class ProfileDetailsVC: UIViewController {
    //IBOutlets
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var addressTF: UITextField!
    @IBOutlet weak var zipTF: UITextField!
    @IBOutlet weak var countryTF: UITextField!
    @IBOutlet weak var cardInfoTF: UITextField!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var saveChangesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional setup
        nameTF.text = user.name
        emailTF.text = user.email
        addressTF.text = user.address
        zipTF.text = user.zipCode
        countryTF.text = user.country
    }
    
    @IBAction func changePassword (_ sender: Any) {
        performSegue(withIdentifier: "PasswordReset", sender: self)
    }
    
    @IBAction func saveChanges (_ sender: Any) {
        let cloudDB = CKContainer.default().privateCloudDatabase
        let accZoneID = CKRecordZone(zoneName: "Account").zoneID
        let accountRecordID = CKRecord.ID(recordName: user.cloudID, zoneID: accZoneID)
        let accountRecord = CKRecord(recordType: "AccountInfo", recordID: accountRecordID)
        
        accountRecord.setValuesForKeys([
            "Name": nameTF.text!,
            "Email": emailTF.text!,
            "StreetAddress": addressTF.text!,
            "ZipCode": zipTF.text!,
            "Country": countryTF.text!,
            "CardInfo": cardInfoTF.text!
        ])
        
        let updateAccount = CKModifyRecordsOperation(recordsToSave: [accountRecord], recordIDsToDelete: [])
        updateAccount.savePolicy = .changedKeys
        //update the record in the DB
        cloudDB.add(updateAccount)
        
        //Update the local record
        user.updateValues(record: accountRecord)
    }
}
