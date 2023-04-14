//
//  NewProductPageVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 2/24/22.
//

import Foundation
import UIKit
import SQLite
import CloudKit
import PhotosUI


class NewProductPageVC: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    //the new product being created
    var newProduct = Product()
    
    //IBOutlets
    @IBOutlet weak var ProductNameTF: UITextField!
    @IBOutlet weak var SupplierTF: UITextField!
    @IBOutlet weak var CategoryTF: UITextField!
    @IBOutlet weak var PriceTF: UITextField!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var productTagLine: UITextField!
    @IBOutlet weak var flagshipFeatureTF: UITextField!
    @IBOutlet weak var featureDescription: UITextField!
    @IBOutlet weak var techSpecSlogan: UITextField!
    @IBOutlet weak var specsDescription: UITextField!
    @IBOutlet weak var photoSelectionButton: UIButton!
    @IBOutlet weak var productImagesCollection: UICollectionView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional set up
        
        //Request Photo Authorization
        photoAuthorization()
                
        //collectionView Setup
        productImagesCollection.dataSource = self
        productImagesCollection.delegate = self
        productImagesCollection.register(UINib(nibName: "ProductInfoCollectionCell", bundle: nil), forCellWithReuseIdentifier: "ProductInfoImageCell")
        
        //Keyboard dismissal
        self.hideKeyboardWhenTappedAround()
    }
    
    func photoAuthorization() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .notDetermined:
                break
            case .restricted, .denied:
                let alert = UIAlertController(title: "Photo Access restriced or denied",
                                              message: "Please allow access to your photo library",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    alert.dismiss(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            case .authorized:
                break
            case .limited:
                let alert = UIAlertController(title: "Photo Access Limited",
                                              message: "Please allow full access to your photo library",
                                              preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (_) in
                    alert.dismiss(animated: true)
                }))
                
                DispatchQueue.main.async {
                    self.present(alert, animated: true)
                }
            }
        }
    }
    
    //MARK: CollectionView funcs
    override func viewDidLayoutSubviews() {
        // REFERENCE 1:  https://stackoverflow.com/a/32584637/18248018
        // REFERENCE 2:  https://stackoverflow.com/a/59206057/18248018
        let collectionViewFlowControl = UICollectionViewFlowLayout()
        collectionViewFlowControl.itemSize = CGSize(width: 378.0, height: 252.0)
        collectionViewFlowControl.scrollDirection = UICollectionView.ScrollDirection.vertical
        productImagesCollection.collectionViewLayout = collectionViewFlowControl
    }
    
    //how many columns
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //how many rows
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    //cell configuration
    //basically an initializer for the cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductInfoImageCell", for: indexPath) as! ProductInfoCollectionCell
        cell.productImage.image = newProduct.infoImages[indexPath.row]
        cell.productImage.contentMode = .scaleAspectFit
        
        return cell
    }
    
    //when user selects a certain cell the image picker appears so they can add new photos
    //Need to select in the correct order
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = PHPickerFilter.images
        config.selectionLimit = 1
            
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }
    
    //MARK: Save New Product
    //IBAction to save the new product
    @IBAction func SaveNewProduct(_ sender: Any) {
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
        
        // IF no empty fields then run the Insert
        //MARK: Modify to save to PUBLIC DB
        if (emptyFields == false) {
            //connect to cloudDB "Products" Zone
            let cloudDB = CKContainer.default().publicCloudDatabase
            //create the 'Product' Record to be saved
            //Specifies that it should go into the "Products" zone
            let recordToAdd = CKRecord(recordType: "Products")
            
            //create an asset to be stored from the image the user selected
            //creates a temporary URL for the images data to be saved in
            //so that we can create a CKAssest from that imageData
            
            var infoImagesAssets: [CKAsset] = []
            
            for image in newProduct.infoImages {
                let imageData = image.jpegData(compressionQuality: 1.0)
                let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(NSUUID().uuidString+".dat")!
                do {
                    try imageData!.write(to: url)
                }
                catch {
                    print("Error \(error)")
                    return
                }
                
                let imageAsset = CKAsset(fileURL: url)
                infoImagesAssets.append(imageAsset)
            }
            
            var infoImages: [CKAsset] = []
            
            for i in 1...3 {
                let asset = infoImagesAssets[i]
                infoImages.append(asset)
            }
        
            recordToAdd.setValuesForKeys([
                "productID": Int64(productsArray.count + 1),
                "productName": ProductNameTF.text!,
                "supplierID": Int64(SupplierTF.text!)!,
                "categoryID": Int64(CategoryTF.text!)!,
                "Price": Double(PriceTF.text!)!,
                "bestSeller": Int64(0),
                "productPhoto": infoImagesAssets[0],
                "slogan": productTagLine.text!,
                "funFeature": flagshipFeatureTF.text!,
                "featureDescription": featureDescription.text!,
                "techSpecSlogan": techSpecSlogan.text!,
                "specsDescription": specsDescription.text!,
                "infoImages": infoImages
            ])
            
            //save record to the public database
            cloudDB.save(recordToAdd) { record, error in
                //handle error
                if let error = error {
                    print(error)
                    return
                }
                if record != nil {
                    DispatchQueue.main.async {
                        //create the product obj to be added to the productsArray
                        let newProduct = Product(record: record!)
                        productsArray.append(newProduct)
                        
                        //Send Notification to reload the tableView data
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
                        
                        //RETURN TO CUSTOMER PAGE
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
}


//MARK: Extensions
extension NewProductPageVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map(\.itemProvider)
        for item in itemProviders {
            if item.canLoadObject(ofClass: UIImage.self) {
                item.loadObject(ofClass: UIImage.self) { (image, error) in
                    DispatchQueue.main.async {
                        if let image = image as? UIImage {
                            //get the collectionView cell that triggered this
                            let indexPath = self.productImagesCollection.indexPathsForSelectedItems
                            let index = indexPath![0].row
                            
                            //set the new image
                            self.newProduct.infoImages[index] = image
                            //reload the collectionView
                            self.productImagesCollection.reloadData()
                        }
                    }
                }
            }
        }
    }
}
