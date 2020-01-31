//
//  RaceScene+Firebase.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/25/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit
import CloudKit
import FirebaseDatabase
import FirebaseAnalytics

/*
 The firebase RaceScene includes logic to create and remove firebase observers for the RaceScene
 that watch for updates in the shared race state, as well as allowing writes to it.
 */
extension RaceScene {
    // MARK: FIREBASE FUNCTIONS METHODS
    func kickoffCountdown() {
        kickoffQueue.async {
            Thread.sleep(forTimeInterval: 2)
            for i in (0...3).reversed() {
                Thread.sleep(forTimeInterval: 1)
                self.realtimeDB.child(Constants.FirebaseFields.gameSessions)
                    .child(self.uuid)
                    .child("countdown")
                    .setValue(i)
            }
        }
    }
    // END OF FIREBASE FUNCTIONS METHODS
    
    
    // MARK: SINGLE DATABASE READ/WRITES
    func createGameSession() {
        
        // initialize game state.
        let gameStateFields = ["countdown" : 4,
                               "gameOver" : 0]
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .setValue(gameStateFields)
        
        // initialize challended position.
        let challengedPosition: [String : Any] = ["level" : 1,
                                                  "microgaming" : 0,
                                                  "position" : "\(self.frame.width / 2 + 20),0",
                                                  "rotation" : 0.0]
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("challenged")
            .setValue(challengedPosition)
        
        // initialize challender position.
        let challengerPosition: [String : Any] = ["level" : 1,
                                                  "microgaming" : 0,
                                                  "position" : "\(self.frame.width / 2 - 20),0",
                                                  "rotation" : 0.0]
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("challenger")
            .setValue(challengerPosition)
        
        // initialize presence.
        let presence = ["challenged" : 0,
                        "challenger" : 0]
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("presence")
            .setValue(presence)
        
        Analytics.logEvent("game_session_created", parameters: ["uuid" : uuid as NSObject])
        print("game session created: \(uuid!)\n")
    }
    
    
    func pushCarType() {
        let carTypePath = (isChallenger ? "challenger" : "challenged")
        
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(carTypePath)
            .child("carType").setValue(UserDefaults.car)
        
        print("pushing car type to: \(uuid!)\n")
    }
    
    
    func pushCarState() {
        let carPath = (isChallenger ? "challenger" : "challenged")
        
        let carState: [String : Any] = ["level" : level,
                                        "microgaming" : 0,
                                        "position" : "\(car.position.x),\(car.position.y)",
                                        "rotation" : car.zRotation]
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(carPath)
            .setValue(carState)
        
        print("pushing car state: \(carState)\n")
    }
    
    
    func pushPresence() {
        let presencePath = (isChallenger ? "challenger" : "challenged")
        
        presence += 1
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("presence")
            .child(presencePath)
            .setValue(presence)
        
        print("pushing presence: \(presence)\n")
    }
    
    
    func pushGameOver() {
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("gameOver")
            .setValue(1)
        
        Analytics.logEvent("game_session_completed", parameters: ["uuid" : uuid as NSObject])
        print("pushing game over: \(uuid!)\n")
    }
    
    
    func deleteGameSession() {
        realtimeDB.child(Constants.FirebaseFields
            .gameSessions)
            .child(uuid)
            .setValue(nil)
        
        Analytics.logEvent("game_session_deleted", parameters: ["uuid" : uuid as NSObject])
        print("deleting game session: \(uuid!)\n")
    }
    // END OF SINGLE DATABASE READ/WRITES
    
    
    // MARK: DATABASE LISTENERS
    func addAllListeners() {
        addOpponentPresenceListener()
        addOpponentCarTypeListener()
        addCountdownListener()
        addOpponentPositionListener()
        addGameOverListener()
    }
    func removeAllListeners() {
        removeOpponentPresenceListener()
        removeOpponentCarTypeListener()
        removeCountdownListener()
        removeOpponentPositionListener()
        removeGameOverListener()
    }
    
    
    func addOpponentPresenceListener() {
        let opponentPath = (isChallenger ? "challenged" : "challenger")
        
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("presence")
            .child(opponentPath)
            .observe(.value, with: { snapshot in
                guard let value = snapshot.value as? Int else { return }
                
                if !self.isOpponentReady {
                    let isChallengedReady = (value > 0)
                    self.isOpponentReady = isChallengedReady
                }
                
                self.opponentPresenceTimeoutTicker = 0
                print("received opponent presence: \(value)\n")
            })
    }
    func removeOpponentPresenceListener() {
        let opponentPath = (isChallenger ? "challenged" : "challenger")
        
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("presence")
            .child(opponentPath)
            .removeAllObservers()
    }
    
    
    func addOpponentCarTypeListener() {
        let opponentPath = (isChallenger ? "challenged" : "challenger")
        
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(opponentPath)
            .child("carType")
            .observe(.value, with: { snapshot in
                guard let value = snapshot.value as? String else { return }
                self.opponentCarType = value
                
                self.removeOpponentCarTypeListener()
                print("received opponent car type: \(value)\n")
            })
    }
    func removeOpponentCarTypeListener() {
        let opponentPath = (isChallenger ? "challenged" : "challenger")
        
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(opponentPath)
            .child("carType").removeAllObservers()
    }
    
    
    func addCountdownListener() {
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("countdown")
            .observe(.value, with: { snapshot in
                guard let value = snapshot.value as? Int else { return }
                
                self.raceCountdown = value
                print("received race countdown: \(value)\n")
            })
    }
    func removeCountdownListener() {
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("countdown")
            .removeAllObservers()
    }
    
    
    func addOpponentPositionListener() {
        let opponentPath = isChallenger ? "challenged" : "challenger"
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(opponentPath)
            .observe(.value, with: { snapshot in
                guard let snapshotValues = snapshot.value as? [String : Any] else { return }
                
                // parse position string.
                let positionString = snapshotValues["position"] as? String
                guard let x = Double(String((positionString?.split(separator: ",")[0])!)),
                    let y = Double(String((positionString?.split(separator: ",")[1])!)) else { return }
                
                // set the opponent's car position, taking into account whether they're ahead of or behind you by a level.
                let level = snapshotValues["level"] as! Int
                if self.level == level {
                    self.opponentCar.position = CGPoint(x: x, y: y)
                } else if self.level < level {
                    self.opponentCar.position = CGPoint(x: CGFloat(x), y: self.frame.height - self.opponentCar.frame.height)
                } else {
                    self.opponentCar.position = CGPoint(x: CGFloat(x), y: 0)
                }
                
                // apply rotation.
                let rotation = snapshotValues["rotation"] as! Double
                self.opponentCar.zRotation = CGFloat(rotation)
                
                print("received opponent state: \(snapshotValues)\n")
            })
    }
    func removeOpponentPositionListener() {
        let opponentPath = isChallenger ? "challenged" : "challenger"
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child(opponentPath)
            .removeAllObservers()
    }
    
    
    func addGameOverListener() {
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("gameOver")
            .observe(.value, with: { snapshot in
                guard let value = snapshot.value as? Int else { return }
                
                let isGameOver = (value == 1)
                if isGameOver {
                    self.exitGame()
                }
                print("received game over update: \(value)\n")
            })
    }
    func removeGameOverListener() {
        realtimeDB.child(Constants.FirebaseFields.gameSessions)
            .child(uuid)
            .child("gameOver")
            .removeAllObservers()
    }
    // END OF DATABASE LISTENERS
}
