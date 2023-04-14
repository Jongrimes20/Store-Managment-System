//
//  WelcomeCustomerVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/14/22.
//

import Foundation
import UIKit
import CloudKit
import LocalAuthentication
import AuthenticationServices

//global declaration of the user obj
var user = User()

class WelcomeCustomerVC: UIViewController {
    //IBOutlets
    @IBOutlet weak var newAccountButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        
        //attempt faceID / touchID
        //add way to only do this if there is something in acc zone
        attemptBiometricSignIn()
    }
    
    //IBActions
    @IBAction func newCustomer(_ sender: Any) {
        performSegue(withIdentifier: "CreateCustomer", sender: self)
    }
    
    @IBAction func signIn(_ sender: Any) {
        //go to manual signin page
        performSegue(withIdentifier: "ToManualSignIn", sender: self)
        
    }
    
    //Helper funcs for biometric login
    func attemptBiometricSignIn() {
        //Attempt FaceID / TouchID
        let context = LAContext()
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) {
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Log Into Your Account", reply: { (wasCorrect, error) in
                //matching biometrics
                if wasCorrect {
                    // check to see if this device matches the one in their credentials
                    Task {
                        if try await self.checkCredentials() == true {
                            //log in
                            
                            //initalize the user obj
                            user = try await self.queryAccountCredentials()
                            
                            //segue to the customer system
                            self.performSegue(withIdentifier: "BiometricSignIn", sender: self)
                        }
                    }
                }
                //biometrics didn't match
                else {
                    return
                }
            })
        }
    }
    
    func queryAccountCredentials() async throws -> User {
        //connect to the users private database
        let cloudDB = CKContainer.default().privateCloudDatabase
        let credZone = CKRecordZone(zoneName: "Account")
        
        let pred = NSPredicate(value: true)
        
        //get the users credentials
        let accountRecord = try await queryRecords(recordType: "AccountInfo", predicate: pred, database: cloudDB, Zone: credZone)
        
        let account = User(accountRecord[0])
        
        return account
    }
    
    func checkCredentials() async throws -> Bool {
        let credentials = try await queryAccountCredentials()
        
        if credentials.deviceIdentifier == UIDevice.current.identifierForVendor!.uuidString {
            return true
        }
        else { return false }
    }
}
