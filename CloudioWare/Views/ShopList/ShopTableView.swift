//
//  ShopTableView.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/26/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit

/*
 The ShopTableView displays DLC cars for sale using ShopTableViewCells.
 */
class ShopTableView: UITableView {
    
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        
        registerCellType()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerCellType()
    }
    
    func registerCellType() {
        let nib = UINib(nibName: Constants.Nibs.shopTableViewCell, bundle: nil)
        self.register(nib, forCellReuseIdentifier: Constants.Nibs.shopTableViewCell)
    }
}
