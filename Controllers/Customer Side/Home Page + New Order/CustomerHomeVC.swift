//
//  CustomerHomeVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import Foundation
import UIKit
import CloudKit

//global declaration of the customers order history
//will query their data on home page load
var orderHistory: [CustomerOrder] = []

class CustomerHomeVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    //IBOutlets
    @IBOutlet weak var header: customerHeader!
    @IBOutlet weak var productCollection: UICollectionView!
    @IBOutlet weak var newOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        header.name.text = user.name
        header.background.image = UIImage(named: "AppleStoreBackground2.jpg")
        header.background.contentMode = .scaleAspectFill
        
        //collectionView setup
        productCollection.dataSource = self
        productCollection.delegate = self
        productCollection.register(UINib(nibName: "ProductCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductCollectionCell")
        
        //Query Order History
        Task {
            orderHistory = try await loadOrderHistory()
        }
    }
    
    //MARK: Query Order History
    func loadOrderHistory() async throws -> [CustomerOrder] {
        //array to be returned
        var orderHistory: [CustomerOrder] = []
    
        //set the cloud database to the users private database
        let cloudDB = CKContainer.default().privateCloudDatabase
        let orderZone = CKRecordZone(zoneName: "Orders")
        
        let pred = NSPredicate(value: true) //true -> return all records
        
        //Get the records matching these criteria
        let orderRecords = try await queryRecords(recordType: "Order", predicate: pred, database: cloudDB, Zone: orderZone)
        
        for record in orderRecords {
            let order = CustomerOrder(record: record)
            orderHistory.append(order)
        }
        
        //returns the products array sorted by date (newest -> oldest)
        return orderHistory.sorted(by: {$0.datePlaced < $1.datePlaced})
    }
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: Collection View funcs
    override func viewDidLayoutSubviews() {
        // REFERENCE 1:  https://stackoverflow.com/a/32584637/18248018
        // REFERENCE 2:  https://stackoverflow.com/a/59206057/18248018
        let collectionViewFlowControl = UICollectionViewFlowLayout()
        collectionViewFlowControl.itemSize = CGSize(width: 150.0, height: 150.0)
        collectionViewFlowControl.scrollDirection = UICollectionView.ScrollDirection.horizontal
        productCollection.collectionViewLayout = collectionViewFlowControl
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return productsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionCell", for: indexPath) as! ProductCollectionCell
        let product = productsArray[indexPath.section]
        
        cell.productName.text = product.Name
        cell.productImg.image = product.productPhoto
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ProductInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ProductInfo" {
            let indexPath = productCollection.indexPathsForSelectedItems![0]
            let product = productsArray[indexPath.section]
            
            let dest = segue.destination as! ProductInfoVC
            dest.product = product
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    
    
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    //MARK: New Order Segue
    @IBAction func startNewOrder(_ sender: Any) {
        performSegue(withIdentifier: "PlaceNewOrder", sender: self)
    }
    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
}

class customerHeader: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: UIImageView!
}
