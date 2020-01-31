//
//  InviteScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit
import CloudKit

/*
 The InvitesScene is where the user can view their game invites to accept or decline them.
 Upon accepting an invite, they'll be transitioned to the RaceScene to start a match.
 */
class InvitesScene: SKScene, UITableViewDelegate, UITableViewDataSource {
    
    // top menu.
    let homeButton = SKButtonNode(text: "Home")
    let separator = SKLabelNode(text: "______________")
    
    // invites table.
    var inviteTableView: InviteTableView!
    var invites: [CKRecord] = [] {
        didSet {
            DispatchQueue.main.async {
                self.inviteTableView.reloadData()
                self.noInvitesLabel.isHidden = (self.invites.count > 0)
            }
        }
    }
    var noInvitesLabel: UILabel!
    let spinner = UIActivityIndicatorView(style: .large)
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // setup UI.
        setupTopBar()
        setupTableView()
        setupNoInvitesLabel()
        setupSpinner()
        
        // retrieve the user's invites.
        getInvites()
        
        // monitor connectivity.
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: Constants.NotificationNames.connectivityChanged, object: nil)
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI METHODS
    private func setupTopBar() {
        // set up back button.
        homeButton.fontSize = 24
        homeButton.position = CGPoint(x: homeButton.frame.width / 2 + 10,
                                      y: self.frame.height - homeButton.frame.height / 2 - 40)
        homeButton.setAction { self.gameViewController.presentHomeScene() }
        self.addChild(homeButton)
        
        // add separator.
        separator.fontColor = ColorPalette.secondaryGray
        separator.position = CGPoint(x: homeButton.position.x, y: homeButton.position.y - 20)
        self.addChild(separator)
    }
    
    
    private func setupTableView() {
        inviteTableView = InviteTableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 80))
        inviteTableView.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 40))
        inviteTableView.rowHeight = 140
        inviteTableView.backgroundColor = ColorPalette.secondaryGray
        inviteTableView.delegate = self
        inviteTableView.dataSource = self
        self.view?.addSubview(inviteTableView)
    }
    
    
    private func setupNoInvitesLabel() {
        noInvitesLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 100))
        self.view?.addSubview(noInvitesLabel)
        noInvitesLabel.text = "No Invites For You"
        noInvitesLabel.textAlignment = .center
        noInvitesLabel.font = UIFont(name: Constants.fontName, size: 32)
        noInvitesLabel.textColor = .black
        noInvitesLabel.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: 3 * self.frame.height / 4))
        noInvitesLabel.isHidden = true
    }
    
    
    private func setupSpinner() {
        self.view?.addSubview(spinner)
        spinner.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2))
        spinner.startAnimating()
    }
    // END OF UI METHODS
    
    
    // MARK: TABLE VIEW DELEGATE METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return invites.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Nibs.inviteTableViewCell, for: indexPath) as! InviteTableViewCell
        let challengeRecord = invites[indexPath.row]
        cell.challengeRecord = challengeRecord
        cell.inviteScene = self
        
        return cell
    }
    // END OF TABLE VIEW DELEGATE METHODS
    
    
    // MARK: DATABASE METHODS
    private func getInvites() {
        CKManager.sharedInstance().getChallenges(closure: { records, error in
            guard let records = records, error == nil else {
                print("error 7: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            self.invites = records
            DispatchQueue.main.async {
                self.spinner.stopAnimating()
                self.spinner.isHidden = true
            }
        })
    }
    // END OF DATABASE METHODS
    
    
    // MARK: CELL CALLBACK METHOD
    func inviteResponse(cell: InviteTableViewCell, accepted: Bool) {
        guard let challenge = cell.challengeRecord else { return }
        CKManager.sharedInstance().respondToChallenge(challenge: challenge, accepted: accepted, closure: { record, error in
            if error != nil {
                print("error 9: \(error?.localizedDescription ?? "unknown error")")
            }
        })
        if accepted {
            gameViewController.presentRaceScene(challenge: challenge, isChallenger: false)
        } else {
            invites.remove(at: inviteTableView.indexPath(for: cell)!.row)
        }
    }
    // END OF CELL CALLBACK METHOD
    
    
    // MARK: CONNECTIVITY SELECTOR
    @objc private func connectivityChanged() {
        if !ConnectivityMonitor.sharedInstance().appOnline {
            gameViewController.presentHomeScene()
        }
    }
    // END OF CONNECTIVITY SELECTOR
}
