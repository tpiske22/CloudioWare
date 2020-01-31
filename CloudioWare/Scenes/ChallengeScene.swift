//
//  ChallengeScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit
import CloudKit

/*
 The ChallengeScene is where the user can search for other users and challenge them to a game.
 After doing so, they'll be transitioned to the LobbyScene to wait for a response.
 */
class ChallengeScene: SKScene, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    // top menu.
    let homeButton = SKButtonNode(text: "Home")
    let separator = SKLabelNode(text: "______________")
    
    // text field for tag searches.
    var tagSearchDropdownView: TagSearchDropdownView!
    var profileRecords: [CKRecord] = [] {
        didSet {
            DispatchQueue.main.async {
                self.tagSearchDropdownView.adjustTableHeight(rowCount: self.profileRecords.count)
                self.tagSearchDropdownView.resultsTable.reloadData()
            }
        }
    }
    var selectedProfileRecord: CKRecord? = nil {
        didSet {
            challengeButton.isHidden = (selectedProfileRecord == nil)
            if let tag = selectedProfileRecord?[Constants.CloudioWareProfileFields.tag] as? String {
                challengeButton.text = "Challenge \(tag)"
            }
        }
    }
    var challengeButton: SKButtonNode!
    let spinner = UIActivityIndicatorView(style: .large)
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // set up the UI elements.
        setupTopBar()
        setupTagSearchDropdownView()
        setupChallengeButton()
        
        // setup spinner.
        self.view?.addSubview(spinner)
        spinner.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2))
        setSpinner(isHidden: true)
        
        // monitor connectivity changes.
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: Constants.NotificationNames.connectivityChanged, object: nil)
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI SETUP HELPERS
    private func setupTopBar() {
        // set up home button.
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
    
    
    private func setupTagSearchDropdownView() {
        // instantiate and place.
        tagSearchDropdownView = TagSearchDropdownView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 50))
        tagSearchDropdownView.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: 4 * self.frame.height / 5))
        
        // assign delegates and add it to the scene's view.
        tagSearchDropdownView.resultsTable.delegate = self
        tagSearchDropdownView.resultsTable.dataSource = self
        tagSearchDropdownView.searchField.delegate = self
        self.view?.addSubview(tagSearchDropdownView)
    }
    
    
    private func setupChallengeButton() {
        challengeButton = SKButtonNode(text: "Challenge")
        challengeButton.idleColor = ColorPalette.red
        challengeButton.selectedColor = ColorPalette.white
        challengeButton.fontSize = 26
        challengeButton.position = CGPoint(x: self.frame.width / 2,
                                           y: challengeButton.frame.height / 2 + 12)
        challengeButton.setAction {
            self.showChallengeMessageAlert()
        }
        self.addChild(challengeButton)
        
        challengeButton.isHidden = true
    }
    
    
    private func buttonsEnabled(_ isEnabled: Bool) {
        DispatchQueue.main.async {
            self.homeButton.isEnabled = isEnabled
            self.challengeButton.isEnabled = isEnabled
        }
    }
    
    
    private func setSpinner(isHidden: Bool) {
        DispatchQueue.main.async {
            self.spinner.isHidden = isHidden
            if isHidden {
                self.spinner.stopAnimating()
            } else {
                self.spinner.startAnimating()
            }
        }
    }
    // END OF UI SETUP HELPERS
    
    
    // MARK: ALERT METHODS
    func showChallengeMessageAlert() {
        let alertController = UIAlertController(title: "Send Your Challenger a Message", message: nil, preferredStyle: .alert)
        alertController.addTextField(configurationHandler: nil)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Send", style: .default, handler: { action in
            self.buttonsEnabled(false)
            self.setSpinner(isHidden: false)
            if let message = alertController.textFields?.first?.text {
                self.sendChallenge(message: message)
            } else {
                self.sendChallenge(message: "")
            }
        }))
        gameViewController.present(alertController, animated: true, completion: nil)
    }
    // END OF ALERT METHODS
    
    
    // MARK: DATABASE METHODS
    private func sendChallenge(message: String) {
        guard let challengedRecord = selectedProfileRecord else { return }
        
        CKManager.sharedInstance().createChallenge(challengedRecord: challengedRecord,
                                                   message: message,
                                                   closure: { record, error in
                                                    guard let record = record, error == nil else {
                                                        print("error 8: \(error?.localizedDescription ?? "unknown error")")
                                                        self.buttonsEnabled(true)
                                                        self.setSpinner(isHidden: true)
                                                        return
                                                    }
                                                    self.gameViewController.presentLobbyScene(challenge: record)
        })
    }
    // END OF DATABASE METHODS
    
    
    // MARK: TABLE VIEW DELEGATE METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profileRecords.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Nibs.tagTableViewCell, for: indexPath) as! TagTableViewCell
        let profileRecord = profileRecords[indexPath.row]
        cell.profileRecord = profileRecord
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedProfileRecord = profileRecords[indexPath.row]
    }
    // END OF TABLE VIEW DELEGATE METHODS
    
    
    // MARK: TEXT FIELD DELEGATE METHODS
    func textFieldDidChangeSelection(_ textField: UITextField) {
        guard let text = textField.text else { return }
        CKManager.sharedInstance().searchForCloudioWareProfiles(tag: text, searchingForExactMatch: false, closure: { records, error in
            guard let records = records, error == nil else {
                print("error 6: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            // filter out your own record so you don't challenge yourself.
            self.profileRecords = records.filter({ ($0[Constants.CloudioWareProfileFields.tag] as! String)
                != (CKManager.sharedInstance().cloudioWareProfile![Constants.CloudioWareProfileFields.tag] as! String)
            })
        })
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    // END OF TEXT FIELD DELEGATE METHODS
    
    
    // MARK: CONNECTIVITY SELECTOR
    @objc func connectivityChanged() {
        gameViewController.presentHomeScene()
    }
    // END OF CONNECTIVITY SELECTOR
}
