//
//  HomePageVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//  View Controller for the Home Page
//

import Foundation
import UIKit
import CloudKit

//Gloabal Vars
var customerArray: [Customer] = []
var ordersArray: [Order] = []
var employeesArray: [Employee] = []
var shippersArray: [Shipper] = []

class HomePageVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //best sellers array
    var bestSellers: [Product] = []
    //new orders array
    var newOrders: [Order] = []
    
    //IBOutlets
    //HeaderTile class defined below
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var headerTile: HeaderTile!
    @IBOutlet weak var employeeTable: UITableView!
    @IBOutlet weak var employeeTableCard: UIView!
    @IBOutlet weak var employeeTableLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    //Best Seller class defined below
    @IBOutlet weak var bestSellerCard: BestSellerCard!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Do any additional setup here
        
        //background color
        backgroundView.backgroundColor = UIColor(rgb: 0xFFEACB)
        
        /*  HEADER TITLE SETUP
         - Manager Name + Text Color
         - Store Number + Text Color
         - Header background Image
         */
        headerTile.managerName.text = manager.Name
        headerTile.managerName.textColor = .white
        headerTile.storeNumber.text = "#\(manager.storeNum)"
        headerTile.storeNumber.textColor = .white
        headerTile.backgroundImage.image = UIImage(named: "AppleStoreBackground2.jpg")
        headerTile.backgroundImage.contentMode = .scaleAspectFill
        headerTile.backgroundImage.layer.cornerRadius = 20
        headerTile.backgroundImage.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        headerTile.backgroundImage.clipsToBounds = true
        scrollView.layer.cornerRadius = 20
        scrollView.clipsToBounds = true
        //only curve the top left corner
        scrollView.layer.maskedCorners = [.layerMinXMaxYCorner]
        
        //employee table setup
        employeeTable.delegate = self
        employeeTable.dataSource = self
        //employee table stacked card design
        employeeTableLabel.textColor = .white
        employeeTable.layer.cornerRadius = 10
        employeeTable.clipsToBounds = true
        employeeTableCard.layer.cornerRadius = 10
        employeeTableCard.clipsToBounds = true
        employeeTableCard.backgroundColor = UIColor(rgb: 0x1B98F5)
        //employeeTableCard shadow
        employeeTableCard.layer.shadowColor = UIColor.black.cgColor
        employeeTableCard.layer.shadowOpacity = 0.3
        employeeTableCard.layer.shadowOffset = .zero
        employeeTableCard.layer.shadowRadius = 10
        employeeTableCard.layer.shadowPath = UIBezierPath(rect: employeeTableCard.bounds).cgPath
        employeeTableCard.layer.shouldRasterize = true
        employeeTableCard.layer.rasterizationScale = UIScreen.main.scale
        
        //Best Seller Card setup
        bestSellerCard.tableView.delegate = self
        bestSellerCard.tableView.dataSource = self
        bestSellerCard.backgroundColor = UIColor(rgb: 0x1B98F5)
        bestSellerCard.headerLabel.textColor = .white
        bestSellerCard.layer.cornerRadius = 10
        bestSellerCard.clipsToBounds = true
        bestSellerCard.tableView.layer.cornerRadius = 10
        bestSellerCard.tableView.clipsToBounds = true
        //BestSellerCard shadow
        bestSellerCard.layer.shadowColor = UIColor.black.cgColor
        bestSellerCard.layer.shadowOpacity = 0.3
        bestSellerCard.layer.shadowOffset = .zero
        bestSellerCard.layer.shadowRadius = 10
        bestSellerCard.layer.shadowPath = UIBezierPath(rect: bestSellerCard.bounds).cgPath
        bestSellerCard.layer.shouldRasterize = true
        bestSellerCard.layer.rasterizationScale = UIScreen.main.scale
        
        Task {
            do {
                employeesArray = try await loadEmployeeArray()
                employeeTable.reloadData()
                
                for product in productsArray {
                    if product.bestSeller == true {
                        bestSellers.append(product)
                    }
                }
                bestSellerCard.tableView.reloadData()
                
                shippersArray = try await loadShipperArray()
            }
            catch {
                print(error)
            }
        }
    }
    
    
    
    //MARK: TableView Funcs
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == employeeTable {
            return employeesArray.count
        }
        return bestSellers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cellToReturn = UITableViewCell()
        
        if tableView == employeeTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "EmployeeCell") as! EmployeeCell
            
            let employee = employeesArray[indexPath.row]
            // Configure the cell here
            cell.employeeName.text = employee.Name
            //need to change this
            cell.department.text = employee.Notes
            cell.IDPhoto.image = UIImage(named: employee.imgName)
            cell.IDPhoto.contentMode = .scaleAspectFill
            cell.IDPhoto.asCircle()
            
            cellToReturn = cell
        }
        else if tableView == bestSellerCard.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "BestSellerCell") as! BestSellerCell
            
            let product = bestSellers[indexPath.row]
            cell.productName.text = product.Name
            cell.productIMG.image = product.productPhoto
            
            cellToReturn = cell
        }
        
        return cellToReturn
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == employeeTable {
            return 76.0
        }
        else if tableView == bestSellerCard.tableView {
            return 81.0
        }
        
        return 0
    }
    
    
    //MARK: Query all data
    /*
     load all data when user gets to the home page for
     a more seamless runtime
     */
    
    //MARK: Query All Products
    func loadProductArray() async throws -> [Product] {
        //array to be returned
        var products: [Product] = []
    
        //set the cloud database to the users private database
        let cloudDB = CKContainer.default().publicCloudDatabase
        let prodZone = CKRecordZone(zoneName: "Products")
        
        let pred = NSPredicate(value: true) //true -> return all records
        
        //Get the records matching these criteria
        let productRecords = try await queryRecords(recordType: "Products", predicate: pred, database: cloudDB, Zone: prodZone)
        
        for record in productRecords {
            let product = Product(record: record)
            products.append(product)
        }
        
        //returns the products array sorted by productID
        return products.sorted(by: { $0.ID < $1.ID })
    }
    
    //MARK: Query All Employees
    func loadEmployeeArray() async throws -> [Employee] {
        //array to be returned
        var employees: [Employee] = []
    
        //set the cloud database to the users private database
        let cloudDB = CKContainer.default().privateCloudDatabase
        let employeeZone = CKRecordZone(zoneName: "Employees")
        
        let pred = NSPredicate(value: true) //true -> return all records
        
        //Get the records matching these criteria
        let employeeRecords = try await queryRecords(recordType: "Employee", predicate: pred, database: cloudDB, Zone: employeeZone)
        
        for record in employeeRecords {
            let employee = Employee(record: record)
            employees.append(employee)
        }
        
        //returns the employees array sorted by ID (L2G)
        return employees.sorted(by: { $0.ID < $1.ID })
    }
    
    //MARK: Query All Shippers
    //Populates the shippersArray used for UIPickerView
    func loadShipperArray() async throws -> [Shipper] {
        //array to be returned
        var shippers: [Shipper] = []
    
        //set the cloud database to the users private database
        let cloudDB = CKContainer.default().privateCloudDatabase
        let shipperZone = CKRecordZone(zoneName: "Shippers")
        
        let pred = NSPredicate(value: true) //true -> return all records
        
        //Get the records matching these criteria
        let shipperRecords = try await queryRecords(recordType: "Shippers", predicate: pred, database: cloudDB, Zone: shipperZone)
        
        for record in shipperRecords {
            let shipper = Shipper(record: record)
            shippers.append(shipper)
        }
        
        //returns the shippers array sorted by ID (L2G)
        return shippers.sorted(by: { $0.ID < $1.ID})
    }



}


//MARK: Header Tile
class HeaderTile: UIView {
    @IBOutlet weak var managerName: UILabel!
    @IBOutlet weak var storeNumber: UILabel!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    //for setting the image for the header tile
    func addBackground(imageName: String = "YOUR DEFAULT IMAGE NAME", contentMode: UIView.ContentMode = .scaleToFill) {
        // setup the UIImageView
        let backgroundImageView = UIImageView(frame: UIScreen.main.bounds)
        backgroundImageView.image = UIImage(named: imageName)
        backgroundImageView.contentMode = contentMode
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backgroundImageView)
        sendSubviewToBack(backgroundImageView)

        // adding NSLayoutConstraints
        let leadingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
        let trailingConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: backgroundImageView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)

        NSLayoutConstraint.activate([leadingConstraint, trailingConstraint, topConstraint, bottomConstraint])
    }
}

//MARK: Employee Table Cell
class EmployeeCell: UITableViewCell {
    @IBOutlet weak var employeeName: UILabel!
    @IBOutlet weak var department: UILabel!
    @IBOutlet weak var IDPhoto: UIImageView!
}

//MARK: Best Seller Card
class BestSellerCard: UIView {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
}
//class for the cells in the Best Seller table
class BestSellerCell: UITableViewCell {
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productIMG: UIImageView!
}


//MARK: Extensions
//UIIMageView Extension for making an image view a circle
extension UIImageView {
    func asCircle() {
        self.layer.borderWidth = 0
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.clipsToBounds = true
    }
}

//For dismissing the keyboard
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIView {
    // Basic shadow
    func dropShadow(scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowOffset = CGSize(width: -1, height: 1)
        self.layer.shadowRadius = 1

        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }

    // color shadow
    func dropShadow(color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOpacity = opacity
        self.layer.shadowOffset = offSet
        self.layer.shadowRadius = radius

        self.layer.shadowPath = UIBezierPath(rect: self.bounds).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
}

extension CACornerMask {
    public static var leftBottom     : CACornerMask { get { return .layerMinXMaxYCorner}}
    public static var rightBottom    : CACornerMask { get { return .layerMaxXMaxYCorner}}
    public static var leftTop        : CACornerMask { get { return .layerMaxXMinYCorner}}
    public static var rightTop       : CACornerMask { get { return .layerMinXMinYCorner}}
}

extension CALayer {

    func roundCorners(_ mask:CACornerMask,corner:CGFloat) {
        self.maskedCorners = mask
        self.cornerRadius = corner
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}

//Date Extension
extension Date {
    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
