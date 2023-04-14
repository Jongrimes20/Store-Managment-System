//
//  ProductsPageVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/23/22.
//

import Foundation
import UIKit
import SQLite
import CloudKit



class ProductsPageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var addProductButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var header: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard dismissal
        self.hideKeyboardWhenTappedAround()
        
        //UX design
        header.backgroundColor = UIColor(rgb: 0x1B98F5)
        headerTitle.textColor = .white
        tableView.layer.cornerRadius = 15
        tableView.layer.maskedCorners = [.layerMinXMaxYCorner]
        tableView.clipsToBounds = true

        //set tableView delegate and dataSource
        tableView.delegate = self
        tableView.dataSource = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
    }
    
    // @objective C tag for the #selector to recognize this func
    @objc func loadList() {
        //reload the tbaleViewData
        self.tableView.reloadData()
    }
    
    // Populating the table with the initial data from the DB
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as! ProductsCell
        
        let product = productsArray[indexPath.row]
        // Configure the cell here
        cell.productName.text = product.Name
        // uses ceiling function to round the price 
        cell.price.text = "$\(round(1000.0 * product.price) / 1000.0)"
        cell.productImage.image = product.productPhoto
        cell.productImage.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        productsArray.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        309
    }
    
    //Segue to the edit page
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to edit page
        performSegue(withIdentifier: "ToEditProductPage", sender: self)
        
    }
    
    //Pass the data through the segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToEditProductPage" {
            //pass data to edit page here
            // get the index path of the selected cell
            let indexPath = tableView.indexPathForSelectedRow
            // get the row of the Index Path and set as index
            let index = indexPath?.row
            // create customer obj to be passed
            let product = productsArray[index!]
            // get in touch with the edit page
            let editPage = segue.destination as! EditProductPageVC
            // pass the customer obj to the edit page
            editPage.product = product
        }
    }
    
    //IBAction for segue to new customer page
    @IBAction func AddButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "ToNewProductPage", sender: self)
    }
    
}

class ProductsCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var price: UILabel!
    @IBOutlet weak var productImage: UIImageView!
    
}
