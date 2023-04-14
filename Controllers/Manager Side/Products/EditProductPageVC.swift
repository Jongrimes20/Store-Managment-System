//
//  EditProductPageVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/24/22.
//

import Foundation
import UIKit
import SQLite
import CloudKit
import PhotosUI


class EditProductPageVC: UIViewController, UINavigationControllerDelegate, PHPickerViewControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    //product obj that's passed during the segue to here
    var product: Product!
    
    //IBOutlets for the text fields
    @IBOutlet weak var ProductNameTF: UITextField!
    @IBOutlet weak var SupplierTF: UITextField!
    @IBOutlet weak var CategoryTF: UITextField!
    @IBOutlet weak var PriceTF: UITextField!
    @IBOutlet weak var SloganTF: UITextField!
    @IBOutlet weak var FeatureTF: UITextField!
    @IBOutlet weak var FeatureDescriptionTF: UITextField!
    @IBOutlet weak var TechSpecsSloganTF: UITextField!
    @IBOutlet weak var SpecsDescriptionTF: UITextField!
    @IBOutlet weak var ProductImagesCollection: UICollectionView!
    @IBOutlet weak var SaveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard dismissal
        self.hideKeyboardWhenTappedAround()
        
        //CollectionView setup
        ProductImagesCollection.delegate = self
        ProductImagesCollection.dataSource = self
        ProductImagesCollection.register(UINib(nibName: "ProductInfoCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductInfoImageCell")
        
        //Set the text fields text to equal the products info
        ProductNameTF.text = product.Name
        SupplierTF.text = String(product.supplierID)
        CategoryTF.text = String(product.categoryID)
        PriceTF.text = String(product.price)
        SloganTF.text = product.slogan
        FeatureTF.text = product.feature
        FeatureDescriptionTF.text = product.featureDescription
        TechSpecsSloganTF.text = product.techSlogan
        SpecsDescriptionTF.text = product.specsDescription
    }
    
    //MARK: CollectionView funcs
    override func viewDidLayoutSubviews() {
        // REFERENCE 1:  https://stackoverflow.com/a/32584637/18248018
        // REFERENCE 2:  https://stackoverflow.com/a/59206057/18248018
        let collectionViewFlowControl = UICollectionViewFlowLayout()
        collectionViewFlowControl.itemSize = CGSize(width: 363.0, height: 252.0)
        collectionViewFlowControl.scrollDirection = UICollectionView.ScrollDirection.vertical
        ProductImagesCollection.collectionViewLayout = collectionViewFlowControl
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductInfoImageCell", for: indexPath) as! ProductInfoCollectionCell
        //for the main product photo
        if indexPath.row == 0 {
            cell.productImage.image = product.productPhoto
            cell.productImage.contentMode = .scaleAspectFit
        }
        else {
            cell.productImage.image = product.infoImages[indexPath.row - 1]
            cell.productImage.contentMode = .scaleAspectFit
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.images
        config.selectionLimit = 1
            
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    
    
    //MARK: Select New Photo
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
            
        let itemProviders = results.map(\.itemProvider)
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            let indexPath = self.ProductImagesCollection.indexPathsForSelectedItems
                            let index = indexPath![0].row
                                
                            self.product.infoImages[index] = image
                            self.ProductImagesCollection.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    //MARK: Update Product Action
    //IBAction to run the UPDATE
    @IBAction func UpdateProduct(_ sender: Any) {
        var emptyFields = false
        
        //First check for any empty fields
        if (ProductNameTF.text == "") {
            ProductNameTF.text = "Please Enter Product Name"
            ProductNameTF.textColor = .red
            emptyFields = true
        }
        if (SupplierTF.text == "") {
            SupplierTF.text = "Please Enter Supplier ID"
            SupplierTF.textColor = .red
            emptyFields = true
        }
        if (CategoryTF.text == "") {
            CategoryTF.text = "Please Enter Category ID"
            CategoryTF.textColor = .red
            emptyFields = true
        }
        if (PriceTF.text == "") {
            PriceTF.text = "Please Enter A Price"
            PriceTF.textColor = .red
            emptyFields = true
        }
        
        // IF no empty fields then run the Update
        //MARK: Save to public DB
        if (emptyFields == false) {
            let cloudDB = CKContainer.default().publicCloudDatabase
            
            let productRecordID = CKRecord.ID(recordName: product.cloudID)
            let productRecord = CKRecord(recordType: "Products", recordID: productRecordID)
            
            //create an asset to be stored from the image the user selected
            //creates a temporary URL for the images data to be saved in
            //so that we can create a CKAssest from that imageData
            var infoImageAssets: [CKAsset] = []
            
            for infoImage in product.infoImages {
                let imageData = infoImage.jpegData(compressionQuality: 1.0)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")!
                do {
                    try imageData!.write(to: url)
                }
                catch {
                    print("Error \(error)")
                    return
                }
                let imageAsset = CKAsset(fileURL: url)
                infoImageAssets.append(imageAsset)
            }
            
            var infoImages: [CKAsset] = []
            for i in 0...2 {
                infoImages.append(infoImageAssets[i])
            }
            
            productRecord.setValuesForKeys([
                "productName": ProductNameTF.text!,
                "supplierID": Int64(SupplierTF.text!)!,
                "categoryID": Int64(CategoryTF.text!)!,
                "Price": Double(PriceTF.text!)!,
                "productPhoto": infoImageAssets[0],
                "slogan": SloganTF.text!,
                "funFeature": FeatureTF.text!,
                "featureDescription": FeatureDescriptionTF.text!,
                "techSpecsSlogan": TechSpecsSloganTF.text!,
                "specsDescription": SpecsDescriptionTF.text!,
                "infoImages": infoImages
            ])
            
            //save record to the public database
            let updateProduct = CKModifyRecordsOperation(recordsToSave: [productRecord], recordIDsToDelete: [])
            updateProduct.savePolicy = .changedKeys
            //execute update
            cloudDB.add(updateProduct)
            
            //update the local object
            self.product.updateValues(record: productRecord)
            
            //Send Notification to reload the tableView data
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
            
            //dismiss page
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
