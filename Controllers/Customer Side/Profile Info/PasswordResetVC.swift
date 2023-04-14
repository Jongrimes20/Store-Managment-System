//
//  PasswordResetVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import Foundation
import CloudKit
import UIKit

class PasswordResetVC: UIViewController {
    //IBOutlets
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var confirmTF: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        
    }
    
    @IBAction func resetPassword(_ sender: Any) {
        var error: Bool = false
        
        if passwordTF.text == "" {
            passwordTF.text = "Please Enter New Password"
            passwordTF.textColor = .red
            error = true
        }
        if confirmTF.text == "" && passwordTF.text != "" {
            confirmTF.text = "Please Confirm New Password"
            confirmTF.textColor = .red
            error = true
        }
        if confirmTF.text != passwordTF.text {
            confirmTF.text = "Make Sure Your Passwords Match"
            confirmTF.textColor = .red
            error = true
        }
        if error == false {
            let cloudDB = CKContainer.default().privateCloudDatabase
            let accZoneID = CKRecordZone(zoneName: "Account").zoneID
            let accountRecordID = CKRecord.ID(recordName: user.cloudID, zoneID: accZoneID)
            let accountRecord = CKRecord(recordType: "AccountInfo", recordID: accountRecordID)
            
            accountRecord.setValuesForKeys([
                "Password": passwordTF.text!
            ])
            
            let updateAccount = CKModifyRecordsOperation(recordsToSave: [accountRecord], recordIDsToDelete: [])
            updateAccount.savePolicy = .changedKeys
            //update the record in the DB
            cloudDB.add(updateAccount)
            
            //Update the local record
            user.updatePassword(record: accountRecord)
            
            //go back to profile details
            self.dismiss(animated: true)
        }
        
    }
    
}
