//
//  InviteTableView.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/22/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit

/*
 The InviteTableView displays the user's invites in InviteTableViewCells.
 */
class InviteTableView: UITableView {
    
    init(frame: CGRect) {
        super.init(frame: frame, style: .plain)
        
        registerCellType()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        registerCellType()
    }
    
    private func registerCellType() {
        let nib = UINib(nibName: Constants.Nibs.inviteTableViewCell, bundle: nil)
        self.register(nib, forCellReuseIdentifier: Constants.Nibs.inviteTableViewCell)
    }
}
