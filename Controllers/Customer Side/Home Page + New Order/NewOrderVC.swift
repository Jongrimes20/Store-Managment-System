//
//  NewOrderVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/18/22.
//

import Foundation
import UIKit
import CloudKit

class NewOrderVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //The CustomerOrder object that is order creates
    var newOrder = CustomerOrder()
    
    //IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var placeOrderButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Additional Setup
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: TableView funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.00
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductToBuyCell") as! ProductToBuyCell
        
        //Configure the Selection Button
        cell.selectButton.tag = indexPath.row
        cell.selectButton.isSelected = false
        cell.selectButton.setImage(UIImage(systemName: "circle"), for: .normal)
        cell.selectButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .selected)
        cell.selectButton.addTarget(self, action: #selector(ItemSelected), for: .touchUpInside)
        
        //the product in the cell
        let product = productsArray[indexPath.row]
        
        //configure cell
        cell.productImg.image = product.productPhoto
        cell.productImg.contentMode = .scaleAspectFit
        cell.productName.text = product.Name
        cell.price.text = "$\(product.price)"
        
        return cell
    }
    // func for when the selectButton is tapped
    // tag is equal to indexPath.row
    @objc func ItemSelected(sender: UIButton) {
        if sender.isSelected == false {
            sender.isSelected = true
            //add product to order
            let product = productsArray[sender.tag]
            newOrder.products.append(product)
            newOrder.quantities.append(1)
            let newPrice = newOrder.orderTotal + product.price
            newOrder.updateTotal(newPreTaxPrice: newPrice)
        }
        else {
            sender.isSelected = false
            //remove product from order
            let product = productsArray[sender.tag]
            newOrder.products.removeAll(where: {$0.Name == product.Name})
            //removing a specific element here doesn't matter since
            //the customer specifies the quantities on the next page
            newOrder.quantities.removeLast()
            let newPrice = newOrder.orderTotal - product.price
            newOrder.updateTotal(newPreTaxPrice: newPrice)
        }
    }
    
    //MARK: Segue to Order Confirmation
    @IBAction func confirmOrder(_ sender: Any) {
        performSegue(withIdentifier: "ConfirmOrder", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmOrder" {
            //pass data to order confirmation page here
            // get in touch with the edit page
            let confirmPage = segue.destination as! OrderConfirmationVC
            // pass the customer obj to the edit page
            confirmPage.orderToConfirm = newOrder
        }
    }

}

//MARK: Product To Buy Cell
class ProductToBuyCell: UITableViewCell {
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var selectButton: UIButton!
}
