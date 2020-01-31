//
//  AboutScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/29/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The AboutScene displays a brief app description.
 Navigate to it from the SettingsScene.
 */
class AboutScene: SKScene {
    
    // top menu.
    let settingsButton = SKButtonNode(text: "Settings")
    let separator = SKLabelNode(text: "______________")
    
    // description.
    var descriptionText: SKLabelNode!
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // set up the UI elements.
        setupTopBar()
        placeAboutText()
    }
    
    
    // MARK: UI SETUP HELPERS
    private func setupTopBar() {
        // set up home button.
        settingsButton.fontSize = 24
        settingsButton.position = CGPoint(x: settingsButton.frame.width / 2 + 10,
                                          y: self.frame.height - settingsButton.frame.height / 2 - 40)
        settingsButton.setAction { self.gameViewController.presentSettingsScene() }
        self.addChild(settingsButton)
        
        // add separator.
        separator.fontColor = ColorPalette.secondaryGray
        separator.position = CGPoint(x: settingsButton.position.x, y: settingsButton.position.y - 20)
        self.addChild(separator)
    }
    
    
    // https://forums.developer.apple.com/thread/82994
    private func placeAboutText() {
        let text = """
        \tCloudioWare Racing is a multiplayer racing game where you can challenge your friends to races online. Win races to earn gold, which you can use in the shop to get new cars.\n
        \tTo start a game, challenge another user in the Challenge screen. Stay in the lobby while you wait for their response. If they accept, a game will automatically begin. If you are challenged, respond in the Invite screen. When racing, stay on the road and avoid the mud! Controls:\n
        accelerate - swipe up\n
        decelerate - swipe down\n
        steer - tilt or drag left and right\n
        (change your steering in the settings)
        """
        descriptionText = SKLabelNode(text: text)
        descriptionText.fontSize = 20
        descriptionText.preferredMaxLayoutWidth = self.frame.width - 20
        descriptionText.position = CGPoint(x: self.frame.width / 2,
                                           y: descriptionText.frame.height / 2)
        descriptionText.numberOfLines = 0
        descriptionText.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.addChild(descriptionText)
    }
    // UI SETUP HELPERS
}
