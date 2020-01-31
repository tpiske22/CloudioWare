//
//  ResultsScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/23/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The ResultsScene is where the user is informed of their race result - win, loss, or forfeit.
 Their win, loss, and gold profile attributes are updated in iCloud as well before a home
 button is presented for them to return to the HomeScene.
 */
class ResultsScene: SKScene {
    
    // race results.
    var wonRace: Bool!
    var dueToConnectionFailure: Bool!
    
    // ui elements.
    var resultLabel: SKLabelNode!
    var winsLabel: SKLabelNode!
    var lossesLabel: SKLabelNode!
    var goldLabel: SKLabelNode!
    let homeButton = SKButtonNode(text: "Home")
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    // MARK: LIFECYCLE
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // set up result label.
        let result = (wonRace ?
            (dueToConnectionFailure ? "You Won By Forfeit!" : "You Won!")
            : (dueToConnectionFailure ? "You Forfeited!" : "You Lost!"))
        resultLabel = SKLabelNode(text: result)
        resultLabel.fontSize = 42
        resultLabel.position = CGPoint(x: self.frame.width / 2, y: 3 * self.frame.height / 4)
        self.addChild(resultLabel)
        
        setupStatsFields()
        
        // set up back button.
        homeButton.isHidden = true
        homeButton.fontSize = 24
        homeButton.position = CGPoint(x: self.frame.width / 2,
                                      y: self.frame.height / 8)
        homeButton.setAction { self.gameViewController.presentHomeScene() }
        self.addChild(homeButton)
        
        updateProfile()
    }
    // END OF LIFECYCLE
    
    
    // MARK: UI METHODS
    private func setupStatsFields() {
        // set up wins label.
        winsLabel = SKLabelNode(text: "Wins: \(CKManager.sharedInstance().cloudioWareProfile?[Constants.CloudioWareProfileFields.wins] as? Int ?? 0)\(wonRace ? " + 1" : "")")
        winsLabel.fontSize = 26
        winsLabel.position = CGPoint(x: self.frame.width / 2, y: 5 * self.frame.height / 8)
        self.addChild(winsLabel)
        
        // set up losses label.
        lossesLabel = SKLabelNode(text: "Losses: \(CKManager.sharedInstance().cloudioWareProfile?[Constants.CloudioWareProfileFields.losses] as? Int ?? 0)\(wonRace ? "" : " + 1")")
        lossesLabel.fontSize = 26
        lossesLabel.position = CGPoint(x: self.frame.width / 2, y: 4 * self.frame.height / 8)
        self.addChild(lossesLabel)
        
        // set up gold label.
        goldLabel = SKLabelNode(text: "Gold: \(CKManager.sharedInstance().cloudioWareProfile?[Constants.CloudioWareProfileFields.gold] as? Int ?? 0)\(wonRace ? " + 20" : " + 3")")
        goldLabel.fontSize = 26
        goldLabel.position = CGPoint(x: self.frame.width / 2, y: 3 * self.frame.height / 8)
        self.addChild(goldLabel)
    }
    // END OF UI METHODS
    
    
    // MARK: DATABASE METHODS
    private func updateProfile() {
        guard let cloudioWareProfile = CKManager.sharedInstance().cloudioWareProfile else { return }
        
        var wins = cloudioWareProfile[Constants.CloudioWareProfileFields.wins] as! Int
        var losses = cloudioWareProfile[Constants.CloudioWareProfileFields.losses] as! Int
        var gold = cloudioWareProfile[Constants.CloudioWareProfileFields.gold] as! Int
        
        if wonRace {
            wins += 1
            gold += 20
        } else {
            losses += 1
            gold += 3
        }
        cloudioWareProfile.setValue(wins, forKey: Constants.CloudioWareProfileFields.wins)
        cloudioWareProfile.setValue(losses, forKey: Constants.CloudioWareProfileFields.losses)
        cloudioWareProfile.setValue(gold, forKey: Constants.CloudioWareProfileFields.gold)
        CKManager.sharedInstance().pushCloudioWareProfileUpdate(closure: { record, error in
            if error != nil {
                print("error 11: \(error?.localizedDescription ?? "unknown error")")
            }
            self.homeButton.isHidden = false
        })
    }
    // END OF DATABASE METHODS
}
