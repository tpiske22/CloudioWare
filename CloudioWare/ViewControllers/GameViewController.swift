//
//  GameViewController.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import CloudKit

/*
 The GameViewController is the primary view controller that directs which scenes are being displayed by
 the skView at which time, deallocates scenes that aren't being displayed, and displays alerts.
 */
class GameViewController: UIViewController {

    static let isOfflineRaceTesting: Bool = false
    
    // scenes.
    var splashScene: SplashScene? = nil
    var homeScene: HomeScene? = nil
    var raceScene: RaceScene? = nil
    var resultsScene: ResultsScene? = nil
    var challengeScene: ChallengeScene? = nil
    var invitesScene: InvitesScene? = nil
    var lobbyScene: LobbyScene? = nil
    var shopScene: ShopScene? = nil
    var settingsScene: SettingsScene? = nil
    var aboutScene: AboutScene? = nil
    
    // our sprite kit view.
    var skView: SKView!
    
    
    // MARK: LIFECYCLE & OVERRIDE METHODS
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up skView.
        skView = self.view as? SKView
        
        // observe connectivity changes.
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: Constants.NotificationNames.connectivityChanged, object: nil)
        
        // respond to the app opening by push notification.
        NotificationCenter.default.addObserver(self, selector: #selector(challengeReceived),
                                               name: Constants.NotificationNames.challengeReceived, object: nil)
        
        if !GameViewController.isOfflineRaceTesting {
            presentSplashScene()
        } else {
            raceScene = RaceScene(size: CGSize(width: self.view.frame.width, height: self.view.frame.height))
            raceScene?.isChallenger = false
            skView.presentScene(raceScene)
        }
    }
    
    
    // in case of shenanigans during a race, toggle listening for to firebase.
    override func viewWillAppear(_ animated: Bool) {
        if !GameViewController.isOfflineRaceTesting {
            raceScene?.addAllListeners()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        if !GameViewController.isOfflineRaceTesting {
            raceScene?.removeAllListeners()
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    // END OF LIFECYCLE & OVERRIDE METHODS
    
    
    // MARK: SCENE CHANGE METHODS
    func presentSplashScene() {
        // set up splash scene.
        splashScene = SplashScene(size: self.view.frame.size)
        splashScene!.gameViewController = self
        
        DispatchQueue.main.async {
            self.skView.presentScene(self.splashScene!, transition: .fade(withDuration: 0.5))
            self.deallocateScenes(otherThan: self.splashScene!)
        }
    }
    
    
    func presentHomeScene() {
        DispatchQueue.main.async {
            // set up home scene.
            self.homeScene = HomeScene(size: self.view.frame.size)
            self.homeScene!.gameViewController = self
            self.skView.presentScene(self.homeScene!, transition: .fade(withDuration: 0.5))
            
            self.deallocateScenes(otherThan: self.homeScene!)
        }
    }
    
    
    func presentRaceScene(challenge: CKRecord, isChallenger: Bool) {
        // set up race scene.
        DispatchQueue.main.async {
            self.raceScene = RaceScene(size: self.view.frame.size)
            self.raceScene!.gameViewController = self
            self.raceScene!.challenge = challenge
            self.raceScene!.isChallenger = isChallenger
            self.skView.presentScene(self.raceScene!, transition: .fade(withDuration: 0.5))
            
            self.deallocateScenes(otherThan: self.raceScene!)
        }
    }
    
    
    func presentResultsScene(wonRace: Bool, dueToConnectionFailure: Bool) {
        // set up results scene.
        DispatchQueue.main.async {
            self.resultsScene = ResultsScene(size: self.view.frame.size)
            self.resultsScene!.gameViewController = self
            self.resultsScene!.wonRace = wonRace
            self.resultsScene!.dueToConnectionFailure = dueToConnectionFailure
            self.skView.presentScene(self.resultsScene!, transition: .fade(withDuration: 0.5))

            self.deallocateScenes(otherThan: self.resultsScene!)
        }
    }
    
    
    func presentChallengeScene() {
        // set up challenge scene.
        DispatchQueue.main.async {
            self.challengeScene = ChallengeScene(size: self.view.frame.size)
            self.challengeScene!.gameViewController = self
            self.skView.presentScene(self.challengeScene!)

            self.deallocateScenes(otherThan: self.challengeScene!)
        }
    }
    
    
    func presentInvitesScene() {
        // set up invites scene.
        DispatchQueue.main.async {
            self.invitesScene = InvitesScene(size: self.view.frame.size)
            self.invitesScene!.gameViewController = self
            self.skView.presentScene(self.invitesScene!)

            self.deallocateScenes(otherThan: self.invitesScene!)
        }
    }
    
    
    func presentLobbyScene(challenge: CKRecord) {
        // set up lobby scene.
        DispatchQueue.main.async {
            self.lobbyScene = LobbyScene(size: self.view.frame.size)
            self.lobbyScene!.gameViewController = self
            self.lobbyScene!.challenge = challenge
            self.skView.presentScene(self.lobbyScene!, transition: .fade(withDuration: 0.5))

            self.deallocateScenes(otherThan: self.lobbyScene!)
        }
    }
    
    
    func presentShopScene() {
        // set up lobby scene.
        DispatchQueue.main.async {
            self.shopScene = ShopScene(size: self.view.frame.size)
            self.shopScene!.gameViewController = self
            self.skView.presentScene(self.shopScene!)

            self.deallocateScenes(otherThan: self.shopScene!)
        }
    }
    
    
    func presentSettingsScene() {
        // set up lobby scene.
        DispatchQueue.main.async {
            self.settingsScene = SettingsScene(size: self.view.frame.size)
            self.settingsScene!.gameViewController = self
            self.skView.presentScene(self.settingsScene!, transition: .fade(withDuration: 0.5))

            self.deallocateScenes(otherThan: self.settingsScene!)
        }
    }
    
    
    func presentAboutScene() {
        // set up lobby scene.
        DispatchQueue.main.async {
            self.aboutScene = AboutScene(size: self.view.frame.size)
            self.aboutScene!.gameViewController = self
            self.skView.presentScene(self.aboutScene!, transition: .fade(withDuration: 0.5))

            self.deallocateScenes(otherThan: self.aboutScene!)
        }
    }
    
    
    private func deallocateScenes(otherThan currentScene: SKScene) {
        // home
        homeScene = (homeScene === currentScene) ? homeScene : nil
        
        // race
        if currentScene !== raceScene {
            Gyro.sharedInstance().stopGyros()
            raceScene?.removeAllListeners() // not sure if this is necessary but...
        }
        raceScene = (raceScene === currentScene) ? raceScene : nil
        
        // results
        resultsScene = (resultsScene === currentScene) ? resultsScene : nil
        
        // challenge
        if currentScene !== challengeScene {
            challengeScene?.spinner.removeFromSuperview()
            challengeScene?.tagSearchDropdownView.removeFromSuperview()
        }
        challengeScene = (challengeScene === currentScene) ? challengeScene : nil
        
        // invites
        if currentScene !== invitesScene {
            invitesScene?.noInvitesLabel.removeFromSuperview()
            invitesScene?.spinner.removeFromSuperview()
            invitesScene?.inviteTableView.removeFromSuperview()
        }
        invitesScene = (invitesScene === currentScene) ? invitesScene : nil
        
        // lobby
        lobbyScene = (lobbyScene === currentScene) ? lobbyScene : nil
        
        // shop
        if currentScene !== shopScene {
            shopScene?.shopTableView.removeFromSuperview()
        }
        shopScene = (shopScene === currentScene) ? shopScene : nil
        
        // settings
        settingsScene = (settingsScene === currentScene) ? settingsScene : nil
        
        // about
        aboutScene = (aboutScene === currentScene) ? aboutScene : nil
    }
    // END OF SCENE CHANGE METHODS
    
    
    // MARK: ALERTS
    func noConnectionAlert() {
        let alertController = UIAlertController(title: "No Connection",
                                                message: "Looks like you lost internet.\nReconnect to play!",
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    // END OF ALERTS
    
    
    // MARK: NOTIFICATION SELECTORS
    @objc private func connectivityChanged() {
        if !(ConnectivityMonitor.sharedInstance().appOnline) {
            noConnectionAlert()
        }
    }
    
    
    // react to receiving a challenge push notification.
    @objc private func challengeReceived() {
        // if the user's opening the app from the push notification, let them load their profile first.
        if skView.scene === splashScene ||
            CKManager.sharedInstance().userRecordID == nil ||
            CKManager.sharedInstance().cloudioWareProfile == nil {
            splashScene!.transitionToInvites = true
        } else if skView.scene !== invitesScene &&
            skView.scene !== raceScene &&
            skView.scene !== lobbyScene {
            presentInvitesScene()
        }
    }
    // END OF NOTIFICATION SELECTORS
}
