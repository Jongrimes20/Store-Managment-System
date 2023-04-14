//
//  SignUpPageVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//

import Foundation
import UIKit
import CloudKit

var manager = StoreManager(name: "", storeNum: 0)

class SignUpPageVC: UIViewController {
    //IBOutlets for UI components
    @IBOutlet weak var NameTextField: UITextField!
    @IBOutlet weak var StoreNumTextField: UITextField!
    @IBOutlet weak var SignInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup on page load
        //check iCloud acc. status
        CKContainer.default().accountStatus { (accountStatus, error) in
            //creates an alert popup depending on the iCloud account status
            switch accountStatus {
            case .available:
//                let cloudAvailable = UIAlertController(title: "iCloud Account Available",
//                                                       message: "your iCloud account will be used to store your stores data",
//                                                       preferredStyle: .alert)
//                cloudAvailable.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
//                    cloudAvailable.dismiss(animated: true)
//                }))
//
//                DispatchQueue.main.async {
//                    self.present(cloudAvailable, animated: true)
//                }
                return
                
                
            case .noAccount:
                let noCloud = UIAlertController(title: "No iCloud Account Available",
                                                message: "this app requires an iCloud account, please set up an account and then try to sign up again",
                                                preferredStyle: .alert)
                noCloud.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    noCloud.dismiss(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(noCloud, animated: true)
                }
                
                
            case .restricted:
                let restrictedCloud = UIAlertController(title: "iCloud Account Is Restricted",
                                                        message: "please unrestrict your iCloud account and try to sign up again",
                                                        preferredStyle: .alert)
                restrictedCloud.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    restrictedCloud.dismiss(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(restrictedCloud, animated: true)
                }
                
                
            //unable to determine iCloud Account status as the defualt case
            default:
                let unableToDetermine = UIAlertController(title: "Unable To Determine iCloud Account Status",
                                                          message: "please make sure you have set up an iCloud account and that it allows this app access",
                                                          preferredStyle: .alert)
                unableToDetermine.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    unableToDetermine.dismiss(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(unableToDetermine, animated: true)
                }
            }
        }


        //Keyboard dismissal
        self.hideKeyboardWhenTappedAround()

    }
    
    
    //segue func
    func ToHomePage() {
        performSegue(withIdentifier: "ToHomePage", sender: self)
    }
    
    
    //MARK: SignIn Button
    @IBAction func SignInButtonTapped(_ sender: UIButton) {
        //error var
        var error = false
        
                
        if (NameTextField.text == "") {
            NameTextField.textColor = .red
            NameTextField.text = "Please Enter Your Name"
            error = true
        }
        if (StoreNumTextField.text == "") {
            StoreNumTextField.textColor = .red
            StoreNumTextField.text = "Please Enter Store #"
            error = true
        }
        //perform segue here
        if (error == false) {
            //determine iCloudStatus
            
            //create the StoreManager obj
            // convert StoreNumberTF.text to an int to pass a param to constructor
            let storeNumber = Int(StoreNumTextField.text!)
            manager.Name = NameTextField.text!
            manager.storeNum = storeNumber!
            ToHomePage()
        }
    }
}
