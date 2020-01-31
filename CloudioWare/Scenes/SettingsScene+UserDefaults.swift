//
//  SettingsScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The SettingsScene is where the user can change their game settings. This is the only screen
 that can be navigated to while the app is offline, because settings are persisted via
 UserDefaults. The following settings can be updated:
 
 Car skin
 Control scheme (tilt/touch)
 Haptics on/off
 
 Get to the AboutScene from here by hitting the question mark button to the top right of the scene.
 */
class SettingsScene: SKScene {
    
    // top menu.
    let homeButton = SKButtonNode(text: "Home")
    let separator = SKLabelNode(text: "______________")
    
    // settings labels.
    let carLabel = SKLabelNode(text: "Car")
    let controlSchemeLabel = SKLabelNode(text: "Control Scheme")
    let hapticsLabel = SKLabelNode(text: "Haptics")
    let soundLabel = SKLabelNode(text: "Sound")
    
    // settings buttons.
    var carButton: SKButtonNode!
    var controlSchemeButton: SKButtonNode!
    var hapticsButton: SKButtonNode!
    var soundButton: SKButtonNode!
    var aboutButton: SKButtonNode!
    
    // car image.
    var carImage: SKSpriteNode!
    
    // user's available cars.
    var usersCars: [String] = []
    var carIndex: Int!
    
    // control schemes.
    let controlSchemes: [String] = ["tilt", "touch"]
    var controlSchemeIndex: Int!
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
                
        // setup UI.
        setupTopBar()
        if let cloudioWareProfile = CKManager.sharedInstance().cloudioWareProfile {
            usersCars = cloudioWareProfile[Constants.CloudioWareProfileFields.cars] as! [String]
            carIndex = usersCars.firstIndex(of: UserDefaults.car)
            controlSchemeIndex = controlSchemes.firstIndex(of: UserDefaults.controlScheme)
            
            setupSettings()
        }
    }
    
    
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
        
        // add question mark for the about page transition.
        aboutButton = SKButtonNode(text: "?", action: { self.gameViewController.presentAboutScene() })
        aboutButton.fontSize = 24
        aboutButton.position = CGPoint(x: self.frame.width - aboutButton.frame.width / 2 - 20, y: homeButton.position.y)
        self.addChild(aboutButton)
    }
    
    
    private func setupSettings() {
        // resize labels.
        carLabel.fontSize = 26
        controlSchemeLabel.fontSize = 26
        hapticsLabel.fontSize = 26
        soundLabel.fontSize = 26
        
        // position labels.
        let center = self.frame.width / 2
        let rowHeight = self.frame.height / 10
        carLabel.position = CGPoint(x: center - carLabel.frame.width / 2 - 10, y: 8 * rowHeight)
        controlSchemeLabel.position = CGPoint(x: center - controlSchemeLabel.frame.width / 2 - 10, y: 7 * rowHeight)
        hapticsLabel.position = CGPoint(x: center - hapticsLabel.frame.width / 2 - 10, y: 6 * rowHeight)
        soundLabel.position = CGPoint(x: center - soundLabel.frame.width / 2 - 10, y: 5 * rowHeight)
        
        // add labels.
        self.addChild(carLabel)
        self.addChild(controlSchemeLabel)
        self.addChild(hapticsLabel)
//        self.addChild(soundLabel)
        
        // instantiate buttons.
        carButton = SKButtonNode(text: UserDefaults.car, action: { self.switchCar() })
        controlSchemeButton = SKButtonNode(text: UserDefaults.controlScheme, action: { self.switchControlScheme() })
        hapticsButton = SKButtonNode(text: UserDefaults.hapticsOn, action: { self.toggleHaptics() })
        soundButton = SKButtonNode(text: UserDefaults.soundOn, action: { self.toggleSound() })
        
        // resize buttons.
        carButton.fontSize = 26
        controlSchemeButton.fontSize = 26
        hapticsButton.fontSize = 26
        soundButton.fontSize = 26
        
        // position buttons.
        positionButton(carButton, row: 8)
        positionButton(controlSchemeButton, row: 7)
        positionButton(hapticsButton, row: 6)
        positionButton(soundButton, row: 5)
        
        // color buttons.
        carButton.idleColor = ColorPalette.green
        controlSchemeButton.idleColor = ColorPalette.green
        hapticsButton.idleColor = ColorPalette.green
        soundButton.idleColor = ColorPalette.green
        
        // add buttons.
        self.addChild(carButton)
        self.addChild(controlSchemeButton)
        self.addChild(hapticsButton)
//        self.addChild(soundButton)
        
        // set initial car image.
        carImage = SKSpriteNode(imageNamed: "light blue")
        updateCarImage()
        let sizeRatio = carImage.frame.height / carImage.frame.width
        carImage.size = CGSize(width: 20, height: 20 * sizeRatio)
        carImage.position = CGPoint(x: carLabel.position.x - carLabel.frame.width / 2 - carImage.frame.width / 2 - 10,
                                    y: carLabel.position.y + carLabel.frame.height / 2)
        self.addChild(carImage)
    }
    
    
    private func updateCarImage() {
        print(UserDefaults.car)
        if let car = Garage.sharedInstance().cars.first(where: { $0.name == UserDefaults.car }) {
            carImage.texture = SKTexture(image: car.image)
        }
    }
    
    
    private func positionButton(_ button: SKButtonNode, row: CGFloat) {
        button.position = CGPoint(x: self.frame.width / 2 + button.frame.width / 2 + 10, y: row * self.frame.height / 10)
    }
    // END OF UI SETUP HELPERS
    
    
    // MARK: BUTTON SELECTORS
    private func switchCar() {
        carIndex = (carIndex + 1) % usersCars.count
        carButton.text = usersCars[carIndex]
        positionButton(carButton, row: 8)
        
        UserDefaults.set(usersCars[carIndex], forKey: Constants.UserDefaults.car)
        updateCarImage()
    }
    
    
    private func switchControlScheme() {
        controlSchemeIndex = (controlSchemeIndex + 1) % controlSchemes.count
        controlSchemeButton.text = controlSchemes[controlSchemeIndex]
        positionButton(controlSchemeButton, row: 7)
        
        UserDefaults.set(controlSchemes[controlSchemeIndex], forKey: Constants.UserDefaults.controlScheme)
    }
    
    
    private func toggleHaptics() {
        
        var toggled: String!
        switch (UserDefaults.hapticsOn) {
        case "true":
            toggled = "false"
        default:
            toggled = "true"
        }
        hapticsButton.text = toggled
        positionButton(hapticsButton, row: 6)
        
        UserDefaults.set(toggled, forKey: Constants.UserDefaults.hapticsOn)
    }
    
    
    private func toggleSound() {
        
        var toggled: String!
        switch (UserDefaults.soundOn) {
        case "true":
            toggled = "false"
        default:
            toggled = "true"
        }
        soundButton.text = toggled
        positionButton(soundButton, row: 5)
        
        UserDefaults.set(toggled, forKey: Constants.UserDefaults.soundOn)
    }
    // END OF BUTTON SELECTORS
}


// for easier access to the defaults we care about.
extension UserDefaults {
    static var car: String {
        return value(forKey: Constants.UserDefaults.car, defaultValue: "light blue")
    }
    
    static var controlScheme: String {
        return value(forKey: Constants.UserDefaults.controlScheme, defaultValue: "tilt")
    }
    
    static var hapticsOn: String {
        return value(forKey: Constants.UserDefaults.hapticsOn, defaultValue: "true")
    }
    
    static var soundOn: String {
        return value(forKey: Constants.UserDefaults.soundOn, defaultValue: "true")
    }
    
    static func value(forKey key: String, defaultValue: String) -> String {
        if let result = UserDefaults().value(forKey: key) as? String {
            return result
        } else {
            UserDefaults().set(defaultValue, forKey: key)
            return defaultValue
        }
    }
    
    static func set(_ value: String, forKey key: String) {
        UserDefaults().set(value, forKey: key)
    }
}
