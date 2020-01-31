//
//  ShopTableViewCell.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/26/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit

/*
 The ShopTableViewCell displays a DLC car's image, name, and price, as well as a buy
 button, which will be enabled only when the user hasn't already bought the car.
 */
class ShopTableViewCell: UITableViewCell {
    
    @IBOutlet weak var carImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var buyButtonBacksplashView: UIView!
    @IBOutlet weak var goldImage: UIImageView!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    
    var shopScene: ShopScene!
    var car: Garage.Car! {
        didSet {
            setUIElements()
        }
    }
    var alreadyOwned: Bool!
    
    
    // MARK: LIFECYCLE
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // make rounded buy buttons.
        buyButtonBacksplashView.layer.cornerRadius = 5
        
        self.backgroundColor = ColorPalette.primaryGray
        self.selectionStyle = .none
    }
    // END OF LIFECYCLE
    
    
    // MARK: UI SETUP
    private func setUIElements() {
        carImageView.image = car.image
        nameLabel.text = car.name
        
        if alreadyOwned {
            priceLabel.text = "Bought"
            buyButtonBacksplashView.backgroundColor = ColorPalette.blue
            goldImage.isHidden = true
            buyButton.isEnabled = false
        } else {
            priceLabel.text = String(car.price!)
        }
    }
    // END OF UI SETUP
    
    
    // MARK: IB ACTIONS
    @IBAction func buyTapped(_ sender: UIButton) {
        shopScene.cellTapped(self)
    }
    // END OF IB ACTIONS
}
