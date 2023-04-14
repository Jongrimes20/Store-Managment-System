//
//  OrderConfirmationVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/18/22.
//

import Foundation
import UIKit
import CloudKit

class OrderConfirmationVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //The order being confirmed
    var orderToConfirm: CustomerOrder!
    
    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var preTaxTotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var subTotal: UILabel!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        tableView.delegate = self
        tableView.dataSource = self
        
        preTaxTotal.text = "Total: $\(orderToConfirm.orderTotal)"
        tax.text = "Tax: $\(orderToConfirm.orderTax)"
        subTotal.text = "Subtotal: $\(orderToConfirm.subTotal)"
    }
    
    //MARK: TableView Funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderToConfirm.products.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductConfirmationCell") as! ProductsOrderedCell
        let product = orderToConfirm.products[indexPath.row]
        var quantity = orderToConfirm.quantities[indexPath.row]
        cell.quantityStepper.value = Double(orderToConfirm.quantities[indexPath.row])
        
        cell.productImg.image = product.productPhoto
        cell.productName.text = product.Name
        cell.quantityTF.text = quantity.description     //description ~ Int as String
        cell.price.text = "$\(product.price)"
        //MARK: Quantity Stepper
        cell.newQuantity = {
            //vars for order pricing
            var preTaxVal: Double = 0.0
            var taxVal: Double = 0.0
            var subTotalVal: Double = 0.0
            
            //For Increasing quantity
            if Int(cell.quantityStepper.value) > quantity {
                cell.quantityTF.text = Int(cell.quantityStepper.value).description
                cell.price.text = "$\(product.price * cell.quantityStepper.value)"
                //Update the order obj
                let newPrice = self.orderToConfirm.orderTotal + product.price
                self.orderToConfirm.updateTotal(newPreTaxPrice: newPrice)
                self.orderToConfirm.quantities[indexPath.row] += 1     // increase by 1
                //Update the 'quantity' var so it doesn't get stuck on 0 & 2
                quantity += 1
                //Update Order Total, Tax, and Subtotal amount
                preTaxVal = self.orderToConfirm.orderTotal
                taxVal = self.orderToConfirm.orderTax
                subTotalVal = self.orderToConfirm.subTotal
            }
            //For decreasing quantity
            if Int(cell.quantityStepper.value) < quantity {
                cell.quantityTF.text = Int(cell.quantityStepper.value).description
                cell.price.text = "$\(product.price * cell.quantityStepper.value)"
                //Update the order obj
                let newPrice = self.orderToConfirm.orderTotal - product.price
                self.orderToConfirm.updateTotal(newPreTaxPrice: newPrice)
                self.orderToConfirm.quantities[indexPath.row] -= 1      // decrease by 1
                //Update the 'quantity' var so it doesn't get stuck on 0 & 2
                quantity -= 1
                //Update Order Total, Tax, and Subtotal amount
                preTaxVal = self.orderToConfirm.orderTotal
                taxVal = self.orderToConfirm.orderTax
                subTotalVal = self.orderToConfirm.subTotal
            }
            self.preTaxTotal.text = "Total: $\(preTaxVal)"
            self.tax.text = "Tax: $\(taxVal)"
            self.subTotal.text = "Subtotal: $\(subTotalVal)"
        }
        
        return cell
    }
    
    //MARK: Place Order
    @IBAction func PlaceOrder(_ sender: Any) {
        let cloudDB = CKContainer.default().privateCloudDatabase
        let orderZone = CKRecordZone(zoneName: "Orders")
        
        let orderRecordID = CKRecord.ID(recordName: UUID().uuidString, zoneID: orderZone.zoneID)
        let orderToAdd = CKRecord(recordType: "Order", recordID: orderRecordID)
        
        var prodIDArray: [Int] = []
        for product in orderToConfirm.products {
            prodIDArray.append(product.ID)
        }
        
        //Need to turn arrays into NSArrays to put them into cloud database
        orderToAdd.setValuesForKeys([
            "datePlaced": Date(),
            "orderTotal": orderToConfirm.subTotal,
            "products": prodIDArray as NSArray,
            "quantities": orderToConfirm.quantities as NSArray
        ])
        
        let addNewOrder = CKModifyRecordsOperation(recordsToSave: [orderToAdd], recordIDsToDelete: [])
        addNewOrder.savePolicy = .allKeys
        // add new record to the database
        cloudDB.add(addNewOrder)
        
        let newOrder = CustomerOrder(record: orderToAdd)
        orderHistory.append(newOrder)
        
        //Send Notification to reload the orderHistory tableView data
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //Segue to home page
        //dismisses this page and the page before it
        self.presentingViewController?.presentingViewController?.dismiss(animated: true)
    }
}

//MARK: Products Ordered Cell
class ProductsOrderedCell: UITableViewCell {
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantityTF: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var price: UILabel!
    
    var newQuantity: (() -> ()) = {}
    @IBAction func quantityChanged(_ sender: UIStepper) {
        newQuantity()
    }
}


//MARK: Extension of Double for rounding
extension Double {
    func rounded(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
