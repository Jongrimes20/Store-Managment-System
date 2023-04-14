//
//  FirstLoadVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/14/22.
//

import Foundation
import UIKit
import CloudKit

var productsArray: [Product] = []

class FirstLoadVC: UIViewController {
    //IBOutlets
    @IBOutlet weak var managerButton: UIButton!
    @IBOutlet weak var customerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        
        // load product data here
        Task {
            productsArray = try await loadProductArray()
            //sort the array by IDs
            productsArray = productsArray.sorted(by: {$0.ID < $1.ID})
        }
    }
    
    //MARK: Query All Products
    func loadProductArray() async throws -> [Product] {
        //set the cloud database to the users private database
        let cloudDB = CKContainer.default().publicCloudDatabase
        
        let pred = NSPredicate(value: true) //true -> return all records
        let query = CKQuery(recordType: "Products", predicate: pred)
        
        let (productResults, _) = try await cloudDB.records(matching: query)
        
        // creates and returns an array of Product objects
        return productResults.compactMap { _, result in
            guard let record = try? result.get(),
                  let product = Product(record: record) as? Product else {return nil}
            return product
        }
    }
    
    //IBActions
    @IBAction func managerSignIn(_ sender: Any) {
        performSegue(withIdentifier: "ManagerSignIn", sender: self)
    }
    
    @IBAction func customerSignIn(_ sender: Any) {
        performSegue(withIdentifier: "Customer", sender: self)
    }
    
}
