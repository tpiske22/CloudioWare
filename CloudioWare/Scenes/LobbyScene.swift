//
//  LobbyScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/22/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit
import CloudKit

/*
 The LobbyScene is where the user waits for a response to one of their challenges. They can
 cancel the challenge at any point and return to the ChallengeScene.
 
 Upon receiving a response, they'll either transition to the RaceScene to begin a match if
 the challenge is accepted or back to the ChallengeScene if it's declined.
 */
class LobbyScene: SKScene {
    
    // top menu.
    let cancelButton = SKButtonNode(text: "Cancel")
    let separator = SKLabelNode(text: "______________")
    
    // waiting elements.
    let cloudiowareImage = SKSpriteNode(imageNamed: "CloudioWare")
    let waitingLabel = SKLabelNode(text: "Waiting for a response...")
    
    // the challenge record we're waiting on a response for.
    var challenge: CKRecord!
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // setup top bar.
        setupTopBar()
        
        // create spinning cloudio for waiting visual.
        createLoadingSpinner()
        
        // add loading label.
        waitingLabel.fontSize = 28
        waitingLabel.position = CGPoint(x: self.frame.width / 2,
                                        y: cloudiowareImage.position.y - cloudiowareImage.frame.width - 4)
        self.addChild(waitingLabel)
        
        // monitor connectivity changes.
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: Constants.NotificationNames.connectivityChanged, object: nil)
        
        // monitor for a challenge response.
        NotificationCenter.default.addObserver(self, selector: #selector(challengeAccepted(_:)),
                                               name: Constants.NotificationNames.challengeAccepted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(challengeDeclined(_:)),
                                               name: Constants.NotificationNames.challengeDeclined, object: nil)
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI SETUP
    private func setupTopBar() {
        // set up home button.
        cancelButton.fontSize = 24
        cancelButton.position = CGPoint(x: cancelButton.frame.width / 2 + 10,
                                      y: self.frame.height - cancelButton.frame.height / 2 - 40)
        cancelButton.setAction {
            self.gameViewController.presentChallengeScene()
            CKManager.sharedInstance().deleteChallenge(challenge: self.challenge, closure: { recordID, error in
                if error != nil {
                    print("error 8: \(error?.localizedDescription ?? "unknown error")")
                }
            })
        }
        self.addChild(cancelButton)
        
        // add separator.
        separator.fontColor = ColorPalette.secondaryGray
        separator.position = CGPoint(x: cancelButton.position.x, y: cancelButton.position.y - 20)
        self.addChild(separator)
    }
    
    
    func createLoadingSpinner() {
        // set spinner image size and position.
        let sizeRatio = cloudiowareImage.frame.height / cloudiowareImage.frame.width
        cloudiowareImage.size = CGSize(width: 80, height: 80 * sizeRatio)
        cloudiowareImage.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        self.addChild(cloudiowareImage)
        
        // create spin animation.
        let spinAnimation = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: 0.7)
        let spinForeverAnimation = SKAction.repeatForever(spinAnimation)
        cloudiowareImage.run(spinForeverAnimation)
    }
    // UI SETUP ENDED
    
    
    // MARK: NOTIFICATION SELECTORS
    @objc private func connectivityChanged() {
        gameViewController.presentHomeScene()
    }
    
    
    @objc private func challengeAccepted(_ notification: NSNotification) {
        let userInfo = notification.userInfo as! [String : String]
        if userInfo[Constants.ChallengeFields.uuid] == challenge[Constants.ChallengeFields.uuid] {
            deleteChallenge()
            self.gameViewController.presentRaceScene(challenge: self.challenge, isChallenger: true)
        }
    }
    
    
    @objc private func challengeDeclined(_ notification: NSNotification) {
        let userInfo = notification.userInfo as! [String : String]
        if userInfo[Constants.ChallengeFields.uuid] == challenge[Constants.ChallengeFields.uuid] {
            deleteChallenge()
            showChallengeDeclinedAlert()
        }
    }
    // END OF NOTIFICATION SELECTORS
    
    
    // MARK: DATABASE METHODS
    private func deleteChallenge() {
        CKManager.sharedInstance().deleteChallenge(challenge: challenge, closure: { recordID, error in
            if error != nil {
                print("error 10: \(error?.localizedDescription ?? "unknown error")")
            }
        })
    }
    // END OF DATABASE METHODS
    
    
    // MARK: ALERT METHODS
    func showChallengeDeclinedAlert() {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: "Challenge Declined",
                                                    message: "\(self.challenge[Constants.ChallengeFields.challengedTag] as! String) said no to your challenge.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                self.gameViewController.presentChallengeScene()
            }))
            self.gameViewController.present(alertController, animated: true, completion: nil)
        }
    }
    // END OF ALERT METHODS
}
