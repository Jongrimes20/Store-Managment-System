//
//  ProductCollectionCell.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/17/22.
//

import UIKit

class ProductCollectionCell: UICollectionViewCell {
    
    //IBOutlets
    @IBOutlet weak var background: UIView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productImg: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        //configure rounded corners and shadow
        background.layer.cornerRadius = 10.0
        background.layer.masksToBounds = true
        
        
        layer.masksToBounds = false
        layer.shadowRadius = 8.0
        layer.shadowOpacity = 0.2
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        // Improve scrolling performance with an explicit shadowPath
        layer.shadowPath = UIBezierPath(
            roundedRect: bounds,
            cornerRadius: 10.0
        ).cgPath
    }

}
