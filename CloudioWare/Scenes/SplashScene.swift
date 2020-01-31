//
//  SplashScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/20/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The SplashScene is more of a loading screen than a splash screen. Appears after the LaunchScreen.storyboard
 to display a spinner while the user's record and CloudioWare profile are pulled, DLC cars are pulled, and
 subscriptions are registered.
 */
class SplashScene: SKScene {
    
    // ui elements.
    let cloudiowareImage = SKSpriteNode(imageNamed: "CloudioWare")
    let loadingLabel = SKLabelNode(text: "Loading...")
    
    // home scene transition.
    var gameViewController: GameViewController!
    var doneLoading: Bool = false {
        didSet {
            if doneLoading {
                registerSubscriptions() {
                    if self.transitionToInvites {
                        self.gameViewController.presentInvitesScene()
                    } else {
                        self.gameViewController.presentHomeScene()
                    }
                }
            }
        }
    }
    var transitionToInvites: Bool = false
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // create spinning cloudio for loading visual.
        createLoadingSpinner()
        
        // add loading label.
        loadingLabel.fontSize = 28
        loadingLabel.position = CGPoint(x: self.frame.width / 2,
                                        y: cloudiowareImage.position.y - cloudiowareImage.frame.width - 4)
        self.addChild(loadingLabel)
        
        if ConnectivityMonitor.sharedInstance().appOnline {
            getUserRecordID()
        } else {
            gameViewController.noConnectionAlert()
            gameViewController.presentHomeScene()
        }
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI SETUP
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
    // END OF UI SETUP
    
    
    // MARK: DATABASE METHODS
    // prompt for a tag and create a new profile.
    func getUserRecordID(attempt: Int = 1) {
        // limit the number of retries.
        if attempt < 6 {
            CKManager.sharedInstance().getUserRecordID(closure: { recordID, error in
                if error != nil {
                    print("error 1: \(error?.localizedDescription ?? "unknown error")")
                    self.getUserRecordID(attempt: attempt + 1)
                    return
                }
                // get user profile from iCloud.
                self.getCloudioWareProfile()
            })
        } else {
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Sign-In Problem", message: "Make sure you're signed into iCloud and re-launch!", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.gameViewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    
    func getCloudioWareProfile(attempt: Int = 1) {
        if attempt < 6 {
            CKManager.sharedInstance().getCloudioWareProfile(closure: { hasProfile, record, error in
                if error != nil {
                    print("error 2: \(error?.localizedDescription ?? "unknown error")")
                    self.getCloudioWareProfile(attempt: attempt + 1)
                    return
                    
                } else if let hasProfile = hasProfile, !hasProfile {
                    self.promptForTag()
                    
                } else if record != nil {
                    CKManager.sharedInstance().setOnlineStatus(isOnline: true, closure: { record, error in
                        if error != nil {
                            print("error 3: \(error?.localizedDescription ?? "unknown error")")
                        }
                    })
                    // get DLC cars.
                    self.getCars()
                    
                } else {
                    print("something else happened when getting cloudioware profile")
                }
            })
        }
    }
    
    
    func getCars(attempt: Int = 1) {
        if attempt < 6 {
            Garage.sharedInstance().getDLCCars(closure: { error in
                if error != nil {
                    print("error 12: \(error?.localizedDescription ?? "unknown error")")
                    self.getCars(attempt: attempt + 1)
                }
                self.doneLoading = true
            })
        }
    }
    
    
    func promptForTag() {
        DispatchQueue.main.async {
            let promptAlertController = UIAlertController(title: "You Must Be New Here",
                                                          message: "What's your CloudioWare tag?",
                                                          preferredStyle: .alert)
            promptAlertController.addTextField(configurationHandler: nil)
            promptAlertController.addAction(UIAlertAction(title: "Register Tag", style: .default, handler: { action in
                if let tag = promptAlertController.textFields?.first?.text {
                    
                    self.isTagAvailable(tag: tag, closure: { isAvailable in
                        guard let isAvailable = isAvailable else { return }
                        
                        if isAvailable {
                            self.createProfile(tag: tag, { success in
                                DispatchQueue.main.async {
                                    if success {
                                        self.showRegistrationOutcomeAlert(tag: tag, success: true)
                                    }
                                }
                            })
                        } else {
                            self.showRegistrationOutcomeAlert(tag: tag, success: false)
                        }
                    })
                }
            }))
            self.gameViewController.present(promptAlertController, animated: true, completion: nil)
        }
    }
    
    
    // check if the tag is available before registering a new profile.
    func isTagAvailable(tag: String, closure: @escaping (Bool?) -> ()) {
        
        CKManager.sharedInstance().searchForCloudioWareProfiles(tag: tag, searchingForExactMatch: true, closure: { records, error in
            guard let records = records, error == nil else {
                print("error 4: \(error?.localizedDescription ?? "unknown error")")
                closure(nil)
                return
            }
            closure(records.isEmpty)
        })
    }
    
    
    // create a profile and set their online status to yes.
    func createProfile(tag: String, _ closure: @escaping (Bool) -> ()) {
        
        CKManager.sharedInstance().createCloudioWareProfile(tag: tag, closure: { record, error in
            if error != nil {
                print("error 5: \(error?.localizedDescription ?? "unknown error")")
                closure(false)
                
            } else if let _ = record {
                CKManager.sharedInstance().setOnlineStatus(isOnline: true, closure: { record, error in
                    if error != nil {
                        print("error 6: \(error?.localizedDescription ?? "unknown error")")
                    }
                })
                closure(true)
            }
        })
    }
    
    
    // register subscriptions after the user profile has been fetched, but not simultaneously to avoid error.
    func registerSubscriptions(closure: @escaping () -> ()) {
        CKManager.sharedInstance().registerChallengedSubscription() {
            CKManager.sharedInstance().registerChallengeResponseSubscription() {
                closure()
            }
        }
    }
    // END OF DATABASE METHODS
    
    
    // MARK: ALERT METHODS
    // alert the user that their tag isn't available.
    func showRegistrationOutcomeAlert(tag: String, success: Bool) {
        DispatchQueue.main.async {
            let alertController: UIAlertController
            if success {
                alertController = UIAlertController(title: nil, message: "Welcome to CloudioWare, \(tag)!", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Thanks", style: .default, handler: { action in
                    self.gameViewController.dismiss(animated: true, completion: nil)
                    self.doneLoading = true
                }))
            } else {
                alertController = UIAlertController(title: nil, message: "Try another tag. \(tag) is already taken.", preferredStyle: .actionSheet)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: { action in
                    self.gameViewController.dismiss(animated: true, completion: nil)
                    self.promptForTag()
                }))
            }
            self.gameViewController.present(alertController, animated: true, completion: nil)
        }
    }
    // END OF ALERT METHODS
}
