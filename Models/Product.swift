//
//  Product.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/16/22.
//
// defines a product struct

import Foundation
import CloudKit
import UIKit

class Product {
    var ID: Int
    var Name: String
    var supplierID: Int
    var categoryID: Int
    var price: Double
    var cloudID: String
    var productPhoto: UIImage
    var bestSeller: Bool
    var infoImages: [UIImage]
    var slogan: String
    var feature: String
    var featureDescription: String
    var techSlogan: String
    var specsDescription: String
    
    
    init () {
        self.ID = productsArray.count
        self.Name = ""
        self.supplierID = 0
        self.categoryID = 0
        self.price = 0.0
        self.cloudID = ""
        self.productPhoto = UIImage(systemName: "camera.viewfinder")!
        self.infoImages = [self.productPhoto, UIImage(systemName: "camera.viewfinder")!, UIImage(systemName: "camera.viewfinder")!, UIImage(systemName: "camera.viewfinder")!]
        self.bestSeller = false
        self.slogan = ""
        self.feature = ""
        self.featureDescription = ""
        self.techSlogan = ""
        self.specsDescription = ""
    }
    
    init (_ id: Int, _ name: String, _ supplierID: Int, _ categoryID: Int, _ price: Double) {
        self.ID = id
        self.Name = name
        self.supplierID = supplierID
        self.categoryID = categoryID
        self.price = price
        self.cloudID = ""
        self.productPhoto = UIImage(systemName: "camera.viewfinder")!
        self.infoImages = [UIImage(systemName: "camera.viewfinder")!, UIImage(systemName: "camera.viewfinder")!, UIImage(systemName: "camera.viewfinder")!, UIImage(systemName: "camera.viewfinder")!]
        self.bestSeller = false
        self.slogan = ""
        self.feature = ""
        self.featureDescription = ""
        self.techSlogan = ""
        self.specsDescription = ""
    }
    
    init (record: CKRecord) {
        self.ID = record["productID"] as! Int
        self.Name = record["productName"] as! String
        self.supplierID = record["supplierID"] as! Int
        self.categoryID = record["categoryID"] as! Int
        self.price = record["Price"] as! Double
        self.cloudID = record.recordID.recordName
        
        //create a UIImage from the records "productPhoto" asset
        let imageAsset = record["productPhoto"] as! CKAsset
        var imageData = Data()
        do {
            imageData = try Data(contentsOf: imageAsset.fileURL!)
        }
        catch {
            print(error)
        }
        self.productPhoto = UIImage(data: imageData)!
        
        //images for info
        /*
         Images:
            1 - Main info Image
            2 - Feature
            3 - Tech Specs
         */
        self.infoImages = []
        let infoImages = record["infoImages"] as! [CKAsset]
        for image in infoImages {
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: image.fileURL!)
                self.infoImages.append(UIImage(data: imageData)!)
            }
            catch {
                print(error)
            }
        }
        
        self.slogan = record["slogan"] as! String
        self.feature = record["funFeature"] as! String
        self.featureDescription = record["featureDescription"] as! String
        self.techSlogan = record["techSpecSlogan"] as! String
        self.specsDescription = record["specsDescription"] as! String
        
        
        //determine if the product is a "bestSeller"
        let bestSellerInt = record["bestSeller"] as! Int
        if bestSellerInt == 1 {
            self.bestSeller = true
        }
        else {
            self.bestSeller = false
        }
    }
    
    func updateValues(record: CKRecord) {
        self.Name = record["productName"] as! String
        self.supplierID = record["supplierID"] as! Int
        self.categoryID = record["categoryID"] as! Int
        self.price = record["Price"] as! Double
        
        //create a UIImage from the records "productPhoto" asset
        let imageAsset = record["productPhoto"] as! CKAsset
        var imageData = Data()
        do {
            imageData = try Data(contentsOf: imageAsset.fileURL!)
        }
        catch {
            print(error)
        }
        self.productPhoto = UIImage(data: imageData)!
        
        //images for info
        /*
         Images:
            1 - Main info Image
            2 - Feature
            3 - Tech Specs
         */
        self.infoImages = []
        let infoImages = record["infoImages"] as! [CKAsset]
        for image in infoImages {
            var imageData = Data()
            do {
                imageData = try Data(contentsOf: image.fileURL!)
                self.infoImages.append(UIImage(data: imageData)!)
            }
            catch {
                print(error)
            }
        }
        
        self.slogan = record["slogan"] as! String
        self.feature = record["funFeature"] as! String
        self.featureDescription = record["featureDescription"] as! String
        self.techSlogan = record["techSpecsSlogan"] as! String
        self.specsDescription = record["specsDescription"] as! String
    }
}
