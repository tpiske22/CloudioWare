//
//  HomeScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The HomeScene is the main hub where the user can navigate to the following other scenes:
 The ChallengeScene
 The InvitesScene
 The ShopScene
 The SettingsScene
 
 Profile info is displayed on the margins of the scene.
 */
class HomeScene: SKScene, UIGestureRecognizerDelegate {
    
    // buttons.
    let challengeButton = SKButtonNode(text: "Challenge a Friend")
    let invitesButton = SKButtonNode(text: "Invites")
    let shopButton = SKButtonNode(text: "Shop")
    let settingsButton = SKButtonNode(text: "Settings")
    
    // labels.
    let cloudiowareLabel = SKLabelNode(text: "CloudioWare Racing")
    let separatorLabel = SKLabelNode(text: "________")
    let tagLabel = SKLabelNode(text: "...")
    let winsLabel = SKLabelNode(text: "Wins...")
    let lossesLabel = SKLabelNode(text: "Losses...")
    let goldLabel = SKLabelNode(text: "...")
    
    // images.
    let cloudiowareImage = SKSpriteNode(imageNamed: "CloudioWare")
    let goldImage = SKSpriteNode(imageNamed: "Gold")
    var disconnectedImage: SKSpriteNode!
    
    // internet connectivity status.
    var isOnline: Bool = true {
        didSet { updateUIForConnectivityState() }
    }
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // watch for connectivity changes.
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: Constants.NotificationNames.connectivityChanged, object: nil)
        
        // lay out buttons, labels, and images, update their values, and set their visibilities.
        setupUIElements()
        updateUIForConnectivityState()
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI METHODS
    // set user's tag, wins, losses, and gold labels.
    private func setupUIElements() {
        // set up layout metrics.
        let columnWidth = self.frame.width / 10
        let rowHeight = self.frame.height / 10
        
        // arrange buttons.
        challengeButton.position = CGPoint(x: 5 * columnWidth, y: 4 * rowHeight)
        invitesButton.position = CGPoint(x: 5 * columnWidth, y: 3 * rowHeight)
        shopButton.position = CGPoint(x: 5 * columnWidth, y: 2 * rowHeight)
        settingsButton.position = CGPoint(x: 5 * columnWidth, y: 1 * rowHeight)
        
        // set button actions.
        challengeButton.setAction   { self.gameViewController.presentChallengeScene() }
        invitesButton.setAction     { self.gameViewController.presentInvitesScene() }
        shopButton.setAction        { self.gameViewController.presentShopScene() }
        settingsButton.setAction    { self.gameViewController.presentSettingsScene() }
        
        // add buttons to the tree.
        self.addChild(challengeButton)
        self.addChild(invitesButton)
        self.addChild(shopButton)
        self.addChild(settingsButton)
        
        // set up and arrange labels and images.
        let sizeRatio = cloudiowareImage.frame.height / cloudiowareImage.frame.width
        cloudiowareImage.size = CGSize(width: 300, height: 300 * sizeRatio)
        cloudiowareImage.position = CGPoint(x: 5 * columnWidth, y: 7.5 * rowHeight)
        cloudiowareImage.constraints = [SKConstraint.positionY(SKRange(upperLimit: self.frame.height
                                                                                    - (cloudiowareImage.frame.height / 2)
                                                                                    - 20))]
        cloudiowareLabel.fontSize = 44
        cloudiowareLabel.fontColor = ColorPalette.blue
        cloudiowareLabel.position = CGPoint(x: 5 * columnWidth, y: 5 * rowHeight)
        
        separatorLabel.position = CGPoint(x: 5 * columnWidth, y: 4.7 * rowHeight)
        
        tagLabel.fontSize = 20
        tagLabel.position = CGPoint(x: 10 * columnWidth, y: 10 * rowHeight)
        
        winsLabel.fontSize = 16
        winsLabel.position = CGPoint(x: -winsLabel.frame.width / 2, y: -winsLabel.frame.height / 2)
        
        goldImage.size = CGSize(width: 30, height: 30)
        goldImage.position = CGPoint(x: 5 * columnWidth, y: -goldImage.frame.height / 2)
        
        goldLabel.fontSize = 16
        goldLabel.position = CGPoint(x: 5 * columnWidth + goldImage.frame.width / 2, y: 0 * rowHeight)
        
        lossesLabel.fontSize = 16
        lossesLabel.position = CGPoint(x: 10 * columnWidth, y: lossesLabel.frame.height / 2)
        
        let disconnectedUIImage = UIImage(systemName: "wifi.slash")!
        disconnectedImage = SKSpriteNode(texture: SKTexture(image: disconnectedUIImage))
        disconnectedImage.position = CGPoint(x: disconnectedImage.frame.width / 2 + 10,
                                             y: self.frame.height - disconnectedImage.frame.height / 2 - 10)
        
        // add labels and images to the tree.
        self.addChild(cloudiowareImage)
        self.addChild(cloudiowareLabel)
        self.addChild(separatorLabel)
        self.addChild(tagLabel)
        self.addChild(winsLabel)
        self.addChild(goldImage)
        self.addChild(goldLabel)
        self.addChild(lossesLabel)
        self.addChild(disconnectedImage)
        
        // set values and adjust constraints.
        guard let profile = CKManager.sharedInstance().cloudioWareProfile else { return }
        let tag = profile[Constants.CloudioWareProfileFields.tag] as! String
        let wins = profile[Constants.CloudioWareProfileFields.wins] as! Int
        let losses = profile[Constants.CloudioWareProfileFields.losses] as! Int
        let gold = profile[Constants.CloudioWareProfileFields.gold] as! Int
        
        tagLabel.text = tag
        tagLabel.constraints = [SKConstraint.positionX(SKRange(upperLimit: self.frame.width
                                                                            - (tagLabel.frame.width / 2)
                                                                            - 10)),
                                SKConstraint.positionY(SKRange(upperLimit: self.frame.height
                                                                            - tagLabel.frame.height / 2
                                                                            - 20))]
        
        winsLabel.text = "\(wins) Won"
        winsLabel.constraints = [SKConstraint.positionX(SKRange(lowerLimit: winsLabel.frame.width / 2
                                                                            + 10)),
                                 SKConstraint.positionY(SKRange(lowerLimit: winsLabel.frame.height / 2
                                                                            + 10))]
        
        goldLabel.text = "\(gold)"
        goldLabel.constraints = [SKConstraint.positionY(SKRange(lowerLimit: goldLabel.frame.height / 2
                                                                            + 10))]
        
        goldImage.constraints = [SKConstraint.positionX(SKRange(upperLimit: goldLabel.position.x
                                                                            - (goldLabel.frame.width / 2)
                                                                            - (goldImage.frame.width / 2)
                                                                            - 4)),
                                 SKConstraint.positionY(SKRange(lowerLimit: goldImage.frame.height / 2
                                                                            + 10))]
        
        lossesLabel.text = "\(losses) Lost"
        lossesLabel.constraints = [SKConstraint.positionX(SKRange(upperLimit: self.frame.width
                                                                                - (lossesLabel.frame.width / 2)
                                                                                - 10)),
                                   SKConstraint.positionY(SKRange(lowerLimit: lossesLabel.frame.height / 2
                                                                                + 10))]
    }
    
    
    private func updateUIForConnectivityState() {
        
        // is the app online?
        let isOnline = ConnectivityMonitor.sharedInstance().appOnline
        
        // buttons.
        challengeButton.isEnabled = isOnline
        invitesButton.isEnabled = isOnline
        shopButton.isEnabled = isOnline
        
        // have we pulled down the user's profile?
        let haveProfile = (CKManager.sharedInstance().cloudioWareProfile != nil)
        
        // labels and images.
        tagLabel.isHidden = !haveProfile
        winsLabel.isHidden = !haveProfile
        goldLabel.isHidden = !haveProfile
        goldImage.isHidden = !haveProfile
        lossesLabel.isHidden = !haveProfile
        disconnectedImage.isHidden = isOnline
    }
    // END OF UI METHODS
    
    
    // MARK: CONNECTIVITY SELECTOR
    @objc func connectivityChanged() {
        updateUIForConnectivityState()
        
        // if no user is logged in and we reconnect, go back to the loading loading screen.
        if ConnectivityMonitor.sharedInstance().appOnline &&
            CKManager.sharedInstance().cloudioWareProfile == nil {
            gameViewController.presentSplashScene()
        }
    }
    // END OF CONNECTIVITY SELECTOR
}
