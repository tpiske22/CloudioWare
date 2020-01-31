//
//  Constants.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import Foundation

/*
 The Constants are for holding constants so I don't constantly misspell everything.
 */
struct Constants {
    
    enum RecordTypes {
        static let cloudioWareProfile = "CloudioWareProfile"
        static let car = "Car"
        static let challenge = "Challenge"
    }
    
    enum CloudioWareProfileFields {
        static let userRecordID = "userRecordID"
        static let tag = "tag"
        static let online = "online"
        static let wins = "wins"
        static let losses = "losses"
        static let gold = "gold"
        static let cars = "cars"
    }
    
    enum CarFields {
        static let name = "name"
        static let price = "price"
        static let image = "image"
    }
    
    enum ChallengeFields {
        static let uuid = "uuid"
        static let challenger = "challenger"
        static let challengerTag = "challengerTag"
        static let challenged = "challenged"
        static let challengedTag = "challengedTag"
        static let message = "message"
        static let status = "status"
    }
    
    enum ChallengeResponses {
        static let pending = "pending"
        static let accepted = "accepted"
        static let declined = "declined"
    }
    
    enum FirebaseFields {
        static let gameSessions = "GameSessions"
    }
    
    enum Nibs {
        static let tagSearchDropdownView = "TagSearchDropdownView"
        static let tagTableViewCell = "TagTableViewCell"
        static let inviteTableViewCell = "InviteTableViewCell"
        static let shopTableViewCell = "ShopTableViewCell"
    }
    
    // notification names.
    enum NotificationNames {
        static let connectivityChanged = NSNotification.Name(rawValue: "Connectivity Changed")
        static let challengeReceived = NSNotification.Name(rawValue: "Challenge Received")
        static let challengeAccepted = NSNotification.Name(rawValue: "Challenge Accepted")
        static let challengeDeclined = NSNotification.Name(rawValue: "Challenge Declined")
    }
    
    // user defaults.
    enum UserDefaults {
        static let car = "car"
        static let controlScheme = "controlScheme"
        static let hapticsOn = "hapticsOn"
        static let soundOn = "soundOn"
    }
    
    // gameplay refresh parameters.
    static let tickLength = TimeInterval(16) //ms = 60fps
    static let writeTickLength = TimeInterval(2000) //ms
    
    // car movement parameters.
    static let maxCarRotation = Double.pi / 2
    static let maxCarVelocity = 2.0
    
    // font name.
    static let fontName = "HelveticaNeue-UltraLight"
}
