//
//  AddNewItemVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/22/22.
//

import Foundation
import UIKit

class AddNewItemVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //order the item is being added to
    var orderToAddTo: CustomerOrder!
    
    //IBOutles
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional Setup
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    //MARK: TableView funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AddItemCell") as! ItemToAddCell
        let product = productsArray[indexPath.row]
        
        //cell configuration
        cell.productImg.image = product.productPhoto
        cell.productName.text = product.Name
        cell.price.text = "$\(product.price)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //get the product in that row
        let product = productsArray[indexPath.row]
        
        //add to the order ~ set initial quantity to 1 bc the user can change it on the previous page
        orderToAddTo.products.append(product)
        orderToAddTo.quantities.append(1)
        
        //send notif to update the tableView on previous page
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
        
        //return to previous page
        self.dismiss(animated: true)
    }
}

class ItemToAddCell: UITableViewCell {
    @IBOutlet weak var productImg: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
}
