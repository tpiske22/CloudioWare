//
//  TagTableViewCell.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import CloudKit

/*
 Displays the tag and online status of a CloudioWareProfile record.
 */
class TagTableViewCell: UITableViewCell {
        
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var onlineStatusLabel: UILabel!
    
    var profileRecord: CKRecord? = nil {
        didSet {
            if profileRecord != nil {
                DispatchQueue.main.async {
                    self.setupLabels()
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = ColorPalette.secondaryGray
    }
    
    
    private func setupLabels() {
        tagLabel.text = profileRecord!.value(forKey: Constants.CloudioWareProfileFields.tag) as? String
        if (profileRecord!.value(forKey: Constants.CloudioWareProfileFields.online) as? String) == "yes" {
            onlineStatusLabel.textColor = ColorPalette.green
            onlineStatusLabel.text = "Online"
        } else {
            onlineStatusLabel.textColor = ColorPalette.primaryGray
            onlineStatusLabel.text = "Offline"
        }
    }
}
