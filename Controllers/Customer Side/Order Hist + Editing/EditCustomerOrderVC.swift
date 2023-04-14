//
//  EditCustomerOrderVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/20/22.
//

import Foundation
import UIKit
import CloudKit


class EditCustomerOrderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //The Order being edited
    var orderToEdit: CustomerOrder!
    
    //IBOutlets
    @IBOutlet weak var trackingNumber: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var paymentTF: UITextField!
    @IBOutlet weak var preTaxTotal: UILabel!
    @IBOutlet weak var tax: UILabel!
    @IBOutlet weak var subtotal: UILabel!
    @IBOutlet weak var updateOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        
        //set the tabelViews delegate and data source
        tableView.delegate = self
        tableView.dataSource = self
        
        //set up the tracking number and "Receipt Info"
        trackingNumber.text = "\(orderToEdit.trackingNum)"
        paymentTF.text = user.cardInfo
        preTaxTotal.text = "Total: $\(orderToEdit.orderTotal)"
        tax.text = "Tax: $\(orderToEdit.orderTax)"
        subtotal.text = "Subtotal: $\(orderToEdit.subTotal)"
        
        //for updating the tableView
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    @objc func loadList() {
        tableView.reloadData()
    }
    
    //MARK: TableView Funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // '+1' to make room for the addItemCell
        return orderToEdit.products.count + 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 121.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //cell to return
        var cell = UITableViewCell()
        
        //Normal Cells
        if indexPath.row != (self.tableView(tableView, numberOfRowsInSection: indexPath.section) - 1) {
            let productCell = tableView.dequeueReusableCell(withIdentifier: "EditOrderCell") as! EditOrderCell
            let product = orderToEdit.products[indexPath.row]
            var quantity = orderToEdit.quantities[indexPath.row]
            productCell.quantityStepper.value = Double(quantity)
            
            //configure cell
            productCell.productImg.image = product.productPhoto
            productCell.productImg.contentMode = .scaleAspectFit
            productCell.productName.text = "\(product.Name)"
            productCell.quantityTF.text = quantity.description
            productCell.price.text = "\(product.price * Double(quantity))"
            
            //MARK: Cell Stepper Code
            productCell.newQuantity = {
                //vars for order pricing
                var preTaxVal: Double = 0.0
                var taxVal: Double = 0.0
                var subTotalVal: Double = 0.0
                
                //For Increasing quantity
                if Int(productCell.quantityStepper.value) > quantity {
                    productCell.quantityTF.text = Int(productCell.quantityStepper.value).description
                    productCell.price.text = "$\(product.price * productCell.quantityStepper.value)"
                    //Update the order obj
                    let newPrice = self.orderToEdit.orderTotal + product.price
                    self.orderToEdit.updateTotal(newPreTaxPrice: newPrice)
                    self.orderToEdit.quantities[indexPath.row] += 1     // increase by 1
                    //Update the 'quantity' var so it doesn't get stuck on 0 & 2
                    quantity += 1
                    //Update Order Total, Tax, and Subtotal amount
                    preTaxVal = self.orderToEdit.orderTotal
                    taxVal = self.orderToEdit.orderTax
                    subTotalVal = self.orderToEdit.subTotal
                }
                //For decreasing quantity
                if Int(productCell.quantityStepper.value) < quantity {
                    productCell.quantityTF.text = Int(productCell.quantityStepper.value).description
                    productCell.price.text = "$\(product.price * productCell.quantityStepper.value)"
                    //Update the order obj
                    let newPrice = self.orderToEdit.orderTotal - product.price
                    self.orderToEdit.updateTotal(newPreTaxPrice: newPrice)
                    self.orderToEdit.quantities[indexPath.row] -= 1      // decrease by 1
                    //Update the 'quantity' var so it doesn't get stuck on 0 & 2
                    quantity -= 1
                    //Update Order Total, Tax, and Subtotal amount
                    preTaxVal = self.orderToEdit.orderTotal
                    taxVal = self.orderToEdit.orderTax
                    subTotalVal = self.orderToEdit.subTotal
                }
                self.preTaxTotal.text = "Total: $\(preTaxVal)"
                self.tax.text = "Tax: $\(taxVal)"
                self.subtotal.text = "Subtotal: $\(subTotalVal)"
            }
            
            //MARK: Delete Item Code ~ FIX THIS
            //not working
            productCell.deleteItem = {
                //remove item from the order
                let prod = self.orderToEdit.products.remove(at: indexPath.row)
                let quant = self.orderToEdit.quantities.remove(at: indexPath.row)
                
                //update order total
                self.orderToEdit.orderTotal -= (prod.price * Double(quant))
                
                //connect to the cloud database
                let cloudDB = CKContainer.default().privateCloudDatabase
                let orderZone = CKRecordZone(zoneName: "Orders")
                let orderRecordID = CKRecord.ID(recordName: self.orderToEdit.trackingNum, zoneID: orderZone.zoneID)
                
                let updateOrder = CKModifyRecordsOperation(recordsToSave: [], recordIDsToDelete: [orderRecordID])
                //execute the update
                cloudDB.add(updateOrder)
                
                //Update the View
                
                let preTaxVal: Double = self.orderToEdit.orderTotal
                let taxVal: Double = self.orderToEdit.orderTax
                let subTotalVal: Double = self.orderToEdit.subTotal
                //update the "recipt" at the bottom
                self.preTaxTotal.text = "$\(preTaxVal)"
                self.tax.text = "$\(taxVal)"
                self.subtotal.text = "$\(subTotalVal)"
                
                //reload the tableView
                self.tableView.reloadData()
            }
            
            cell = productCell
        }
        //MARK: "Add Item" button/cell
        else {
            let addItemCell = tableView.dequeueReusableCell(withIdentifier: "AddItemCell") as! AddItemCell
            
            //segue to a new page where all items are presented
            addItemCell.addItem = {
                self.performSegue(withIdentifier: "AddNewItem", sender: self)
            }
            
            cell = addItemCell
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddNewItem" {
            let dest = segue.destination as! AddNewItemVC
            dest.orderToAddTo = orderToEdit
        }
    }
    
    //MARK: Update Order
    @IBAction func updateOrder(_ sender: UIButton) {
        let cloudDB = CKContainer.default().privateCloudDatabase
        let orderZone = CKRecordZone(zoneName: "Orders")
        let recordID = CKRecord.ID(recordName: orderToEdit.trackingNum, zoneID: orderZone.zoneID)
        let orderRecord = CKRecord(recordType: "Order", recordID: recordID)
        
        var prodIDs: [Int] = []
        
        for product in orderToEdit.products {
            prodIDs.append(product.ID)
        }
        
        orderRecord.setValuesForKeys([
            "orderTotal": orderToEdit.subTotal,
            "products": prodIDs as NSArray,
            "quantities": orderToEdit.quantities as NSArray
        ])
        
        let updateOrder = CKModifyRecordsOperation(recordsToSave: [orderRecord], recordIDsToDelete: [])
        updateOrder.savePolicy = .changedKeys
        //execute update
        cloudDB.add(updateOrder)
        
        //send notif to update the tableView on previous page
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //go back to order history page
        self.dismiss(animated: true)
    }
}

class EditOrderCell: UITableViewCell {
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var quantityTF: UITextField!
    @IBOutlet weak var quantityStepper: UIStepper!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var trashButton: UIButton!
    
    //func declaration for the quantityStepper
    var newQuantity: (() -> ()) = {}
    @IBAction func quantityChanged(_ sender: UIStepper) {
        newQuantity()
    }
    
    //func declaration for the trash button
    var deleteItem: (() -> ()) = {}
    @IBAction func trashItem(_ sender: UIButton) {
        deleteItem()
    }
    
}

class AddItemCell: UITableViewCell {
    @IBOutlet weak var addItemButton: UIButton!
    
    var addItem: (() -> ()) = {}
    @IBAction func addNewItem(_ sender: UIButton) {
        addItem()
    }
}
