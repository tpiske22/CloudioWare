//
//  SearchDropdown.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import CloudKit

/*
 The TagSearchDropdownView is used to search for user profile tags in the ChallengeScene. It searches for and
 displays all tags in the CloudKid container in its TagTableView as the user types.
 */
// https://medium.com/better-programming/swift-3-creating-a-custom-view-from-a-xib-ecdfe5b3a960
class TagSearchDropdownView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var resultsTable: TagTableView!
    
    let rowHeight: Int = 80
    
    
    // MARK: INITIALIZERS
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    
    private func commonInit() {
        Bundle.main.loadNibNamed(Constants.Nibs.tagSearchDropdownView, owner: self, options: nil)
        self.addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // set up results table view size.
        adjustTableHeight(rowCount: 0)
    }
    // MARK END OF INITIALIZERS
    
    
    // MARK: ANIMATION METHODS
    // change the size of the table to match the result count.
    func adjustTableHeight(rowCount: Int) {
        self.frame.size = CGSize(width: self.frame.width,
                                 height: searchField.frame.height + CGFloat(min(rowHeight * rowCount, 4 * rowHeight)))
    }
    // END OF ANIMATION METHODS
}
