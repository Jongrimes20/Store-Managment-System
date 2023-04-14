//
//  OrderHistoryVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import Foundation
import UIKit
import CloudKit

class OrderHistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //IBOutlets
    @IBOutlet weak var ordersCard: OrdersCard!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        ordersCard.tableView.delegate = self
        ordersCard.tableView.dataSource = self
        
        ordersCard.layer.cornerRadius = 10
        ordersCard.layer.masksToBounds = true
        ordersCard.tableView.layer.cornerRadius = 10
        ordersCard.tableView.layer.masksToBounds = true
        
        
        //for updating the tableView
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func loadList() {
        ordersCard.tableView.reloadData()
    }
    
    //MARK: TableView funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderHistory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 118.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderHistoryCell") as! ordersCell
        let order = orderHistory[indexPath.row]
        //for deleting an order
        let row = indexPath.row
        //used for transefrring this order over to the edit page
        cell.optionsButton.tag = indexPath.row
        
        //configure cell
        var prodsString = ""
        for product in order.products {
            let prodStr = productsArray[product.ID - 1].Name
            prodsString.append("\(prodStr), ")
        }
        //removes the trailing ", " from the prodsString
        prodsString.removeLast(2)
        cell.products.text = prodsString
        cell.datePlaced.text = "Date Placed: \(order.datePlaced)"
        cell.orderTotal.text = "$\(order.orderTotal)"
        cell.trackingNumber.text = "Tracking #: \(order.trackingNum)"
        
        /*
         configure the cell's option button
         has 2 options:
            ~ Edit Order -> segue to edit order page
            ~ Delete Order -> delete locally & in database then update tableView
         */
        //Handlers for the menu options
        let editHandler = { (action: UIAction) in
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            self.performSegue(withIdentifier: "EditOrder", sender: self)
        }
        
        let deleteHandler = { (action: UIAction) in
            //delete in the cloud first
            let cloudDB = CKContainer.default().privateCloudDatabase
            let orderZone = CKRecordZone(zoneName: "Orders")
            let orderRecord = CKRecord.ID(recordName: order.trackingNum, zoneID: orderZone.zoneID)
            
            let deleteRecord = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: [orderRecord])
            //execute the deletion of the record
            cloudDB.add(deleteRecord)
            //delete the order locally
            orderHistory.remove(at: row)
            //update tableView
            self.ordersCard.tableView.reloadData()
        }
        
        cell.optionsButton.menu = UIMenu(children: [
            UIAction(title: "Edit Order", handler: editHandler),
            UIAction(title: "Delete Order",handler: deleteHandler)
        ])
        
        
        return cell
    }
    
    //for transferring the data to the edit page
    //Some how gets the order on the opposite side of the array???
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EditOrder" {
            let indexPath = ordersCard.tableView.indexPathForSelectedRow
            let index = indexPath?.row
            let order = orderHistory[index!]
            let dest = segue.destination as! EditCustomerOrderVC
            dest.orderToEdit = order
        }
    }
    
}

class OrdersCard: UIView {
    @IBOutlet weak var tableView: UITableView!
}
class ordersCell: UITableViewCell {
    @IBOutlet weak var products: UILabel!
    @IBOutlet weak var datePlaced: UILabel!
    @IBOutlet weak var trackingNumber: UILabel!
    @IBOutlet weak var orderTotal: UILabel!
    @IBOutlet weak var optionsButton: UIButton!
}
