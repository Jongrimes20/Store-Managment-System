//
//  ProductInfoVC.swift
//  Store Managment System
//
//  Created by Jon Grimes on 4/24/22.
//

import Foundation
import UIKit

class ProductInfoVC: UIViewController {
    //Product whose Info is being displayed
    var product: Product!
    
    //IBOutlets
    @IBOutlet weak var infoImage: UIImageView!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var slogan: GradientLabel!
    @IBOutlet weak var featureImage: UIImageView!
    @IBOutlet weak var featureSlogan: UILabel!
    @IBOutlet weak var featureDetails: GradientLabel!
    @IBOutlet weak var techImage: UIImageView!
    @IBOutlet weak var techSlogan: GradientLabel!
    @IBOutlet weak var techDetails: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Additional setup
        view.backgroundColor = .black
        
        infoImage.image = product.infoImages[0]
        infoImage.contentMode = .scaleAspectFill
        productName.text = product.Name
        //for photos with black backgrounds
        if product.Name == "iPhone 13 Pro" {
            productName.textColor = .black
        }
        else {
            productName.textColor = .white
        }
        
        slogan.text = product.slogan
        //Make Slogan A Gradient
        slogan.gradientColors = [UIColor(rgb: 0xFFBE0B).cgColor, UIColor(rgb: 0xFF006E).cgColor, UIColor(rgb: 0x8338EC).cgColor]
        
        featureImage.image = product.infoImages[1]
        featureImage.contentMode = .scaleAspectFill
        featureSlogan.text = product.feature
        featureDetails.text = product.featureDescription
        //add gradient to feature info
        if product.Name == "iPad Pro" || product.Name == "AirPod Pros" {
            featureDetails.gradientColors = [UIColor(rgb: 0xFFBE0B).cgColor, UIColor(rgb: 0xFF006E).cgColor, UIColor(rgb: 0x8338EC).cgColor]
        }
        else {
            featureDetails.gradientColors = [UIColor(white: 1.0, alpha: 1.0).cgColor, UIColor(white: 1.0, alpha: 1.0).cgColor]
        }
        
        techImage.image = product.infoImages[2]
        techImage.contentMode = .scaleAspectFill
        techSlogan.text = product.techSlogan
        //Make Tech Slogan a gradient
        techSlogan.gradientColors = [UIColor(rgb: 0xFFBE0B).cgColor, UIColor(rgb: 0xFF006E).cgColor, UIColor(rgb: 0x8338EC).cgColor]
        techDetails.text = product.specsDescription
        techDetails.textColor = .green
    }
}


class GradientLabel: UILabel {
    var gradientColors: [CGColor] = []

    override func drawText(in rect: CGRect) {
        if let gradientColor = drawGradientColor(in: rect, colors: gradientColors) {
            self.textColor = gradientColor
        }
        super.drawText(in: rect)
    }

    private func drawGradientColor(in rect: CGRect, colors: [CGColor]) -> UIColor? {
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.saveGState()
        defer { currentContext?.restoreGState() }

        let size = rect.size
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                        colors: colors as CFArray,
                                        locations: nil) else { return nil }

        let context = UIGraphicsGetCurrentContext()
        context?.drawLinearGradient(gradient,
                                    start: CGPoint.zero,
                                    end: CGPoint(x: size.width, y: 0),
                                    options: [])
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let image = gradientImage else { return nil }
        return UIColor(patternImage: image)
    }
}
