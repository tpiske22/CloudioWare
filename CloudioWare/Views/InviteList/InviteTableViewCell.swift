//
//  InviteTableViewCell.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/22/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import CloudKit
import SpriteKit

/*
 The InviteTableViewCell displays the challenger tag and message attributes of a Challenge CKRecord.
 It also shows accept and decline buttons for the user, which trigger a cell selection function in
 the InviteScene that contains the cell's InviteTableView.
 */
class InviteTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var declineButton: UIButton!
    
    var inviteScene: InvitesScene!
    var challengeRecord: CKRecord? = nil {
        didSet {
            DispatchQueue.main.async {
                self.setLabels()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = ColorPalette.primaryGray
        self.selectionStyle = .none
    }
    
    
    private func setLabels() {
        tagLabel.text = challengeRecord![Constants.ChallengeFields.challengerTag] as? String
        messageLabel.text = challengeRecord![Constants.ChallengeFields.message] as? String
    }
    
    
    // MARK: IB ACTIONS
    @IBAction func acceptTapped(_ sender: UIButton) {
        inviteScene.inviteResponse(cell: self, accepted: true)
    }
    
    @IBAction func declineTapped(_ sender: UIButton) {
        inviteScene.inviteResponse(cell: self, accepted: false)
    }
    // END OF IB ACTIONS
}
