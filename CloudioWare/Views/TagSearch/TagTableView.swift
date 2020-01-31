//
//  DropdownTableView.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit

/*
 The TagTableView displays results to users' profile tag searches in TagTableViewCells.
 */
class TagTableView: UITableView {
    
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        
        registerCells()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerCells()
    }
    
    private func registerCells() {        
        let nib = UINib(nibName: Constants.Nibs.tagTableViewCell, bundle: nil)
        self.register(nib, forCellReuseIdentifier: Constants.Nibs.tagTableViewCell)
    }
}
