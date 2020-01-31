//
//  CKManager.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import CloudKit

/*
 The CKManager is a singleton that handles calls to the iCloud container, iCloud.tpiske-cloudioware.
 */
class CKManager {
    
    // singleton.
    static var instance: CKManager? = nil
    
    // cloud kit container and databases.
    let container: CKContainer = CKContainer.default()
    let publicDB: CKDatabase = CKContainer.default().publicCloudDatabase
    let privateDB: CKDatabase = CKContainer.default().privateCloudDatabase
        
    // user info.
    var userRecordID: CKRecord.ID? = nil
    var cloudioWareProfile: CKRecord? = nil
    
    
    // MARK: INITIALIZATION
    static func sharedInstance() -> CKManager {
        if instance == nil { instance = CKManager() }
        return instance!
    }
    
    private init() { }
    // END OF INITIAILIZATION
    
    
    // MARK: DATABASE QUERY METHODS
    func getUserRecordID(closure: @escaping (CKRecord.ID?, Error?) -> ()) {
        container.fetchUserRecordID(completionHandler: { recordID, error in
            guard let recordID = recordID, error == nil else {
                closure(nil, error)
                return
            }
            print("user record ID retrieved: \(recordID)\n\n")
            self.userRecordID = recordID
            closure(recordID, nil)
        })
    }
    
    
    func getCloudioWareProfile(closure: @escaping (Bool?, CKRecord?, Error?) -> ()) {
        guard let recordID = userRecordID else {
            closure(nil, nil, nil)
            return
        }
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let predicate = NSPredicate(format: "\(Constants.CloudioWareProfileFields.userRecordID) == %@", reference)
        let query = CKQuery(recordType: Constants.RecordTypes.cloudioWareProfile, predicate: predicate)
        
        publicDB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            if error != nil {
                closure(nil, nil, error)
            } else if let record = records?.first {
                print("cloudioware profile retrieved: \(record)\n\n")
                self.cloudioWareProfile = record
                closure(true, record, nil)
            } else {
                closure(false, nil, nil)
            }
        })
    }
    
    
    func searchForCloudioWareProfiles(tag: String, searchingForExactMatch: Bool, closure: @escaping ([CKRecord]?, Error?) -> ()) {
        if tag.isEmpty {
            closure([], nil)
            return
        }
        let predicate: NSPredicate
        if searchingForExactMatch   { predicate = NSPredicate(format: "tag == %@", tag) }
        else                        { predicate = NSPredicate(format: "tag BEGINSWITH %@", tag) }
        
        let query = CKQuery(recordType: Constants.RecordTypes.cloudioWareProfile, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            guard let records = records, error == nil else {
                closure(nil, error)
                return
            }
            print("retrieved searched cloudioware profiles for tag \(tag): \(records)\n\n")
            closure(records, nil)
        })
    }
    
    
    func createCloudioWareProfile(tag: String, closure: @escaping (CKRecord?, Error?) -> ()) {
        guard let recordID = userRecordID else {
            closure(nil, nil)
            return
        }
        let reference = CKRecord.Reference(recordID: recordID, action: .none)
        let cars: [String] = ["Brown", "Green", "Pink", "Light Blue"]
        
        let record = CKRecord(recordType: Constants.RecordTypes.cloudioWareProfile)
        record.setValue(reference, forKey: Constants.CloudioWareProfileFields.userRecordID)
        record.setValue(tag, forKey: Constants.CloudioWareProfileFields.tag)
        record.setValue("yes", forKey: Constants.CloudioWareProfileFields.online)
        record.setValue(0, forKey: Constants.CloudioWareProfileFields.wins)
        record.setValue(0, forKey: Constants.CloudioWareProfileFields.losses)
        record.setValue(0, forKey: Constants.CloudioWareProfileFields.gold)
        record.setValue(cars, forKey: Constants.CloudioWareProfileFields.cars)
        
        publicDB.save(record, completionHandler: { record, error in
            guard let record = record, error == nil else {
                closure(nil, error)
                return
            }
            print("cloudioware profile created: \(record)\n\n")
            self.cloudioWareProfile = record
            closure(record, nil)
        })
    }
    
    
    func pushCloudioWareProfileUpdate(closure: @escaping (CKRecord?, Error?) -> ()) {
        guard let cloudioWareProfile = self.cloudioWareProfile else {
            closure(nil, nil)
            return
        }
        
        publicDB.save(cloudioWareProfile, completionHandler: { record, error in
            guard let record = record, error == nil else {
                closure(nil, error)
                return
            }
            print("cloudioware profile updated: \(record)\n\n")
            closure(record, nil)
        })
    }
    
    
    func setOnlineStatus(isOnline: Bool, closure: @escaping (CKRecord?, Error?) -> ()) {
        guard let record = self.cloudioWareProfile else {
            closure(nil, nil)
            return
        }
        let status = (isOnline ? "yes" : "no")
        record.setValue(status, forKey: Constants.CloudioWareProfileFields.online)
        
        publicDB.save(record, completionHandler: { record, error in
            guard let record = record, error == nil else {
                closure(nil, error)
                return
            }
            print("updated cloudioware online status: \(record)\n\n")
            self.cloudioWareProfile = record
            closure(record, nil)
        })
    }
    
    
    func getChallenges(closure: @escaping ([CKRecord]?, Error?) -> ()) {
        // the user should never be able to get here without their userRecordID, but just in case...
        guard let userRecordID = self.userRecordID else {
            closure(nil, nil)
            return
        }
        let predicate = NSPredicate(format: "challenged == %@", userRecordID)
        let query = CKQuery(recordType: Constants.RecordTypes.challenge, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            guard let records = records, error == nil else {
                closure(nil, error)
                return
            }
            print("retrieved user challenges: \(records)\n\n")
            closure(records, nil)
        })
    }
    
    
    func createChallenge(challengedRecord: CKRecord, message: String, closure: @escaping (CKRecord?, Error?) -> ()) {
        guard let cloudioWareProfile = self.cloudioWareProfile else {
            closure(nil, nil)
            return
        }
        let challenger = cloudioWareProfile[Constants.CloudioWareProfileFields.userRecordID] as! CKRecord.Reference
        let challengerTag = cloudioWareProfile[Constants.CloudioWareProfileFields.tag] as! String
        let challenged = challengedRecord[Constants.CloudioWareProfileFields.userRecordID] as! CKRecord.Reference
        let challengedTag = challengedRecord[Constants.CloudioWareProfileFields.tag] as! String
        
        // set the challenge record's initial values.
        let challenge = CKRecord(recordType: Constants.RecordTypes.challenge)
        challenge.setValue(UUID().uuidString, forKey: Constants.ChallengeFields.uuid)
        challenge.setValue(challenger, forKey: Constants.ChallengeFields.challenger)
        challenge.setValue(challengerTag, forKey: Constants.ChallengeFields.challengerTag)
        challenge.setValue(challenged, forKey: Constants.ChallengeFields.challenged)
        challenge.setValue(challengedTag, forKey: Constants.ChallengeFields.challengedTag)
        challenge.setValue(message, forKey: Constants.ChallengeFields.message)
        challenge.setValue(Constants.ChallengeResponses.pending, forKey: Constants.ChallengeFields.status)
        
        publicDB.save(challenge, completionHandler: { record, error in
            guard let record = record, error == nil else {
                closure(nil, error)
                return
            }
            print("challenged created: \(record)\n\n")
            closure(record, nil)
        })
    }
    
    
    func deleteChallenge(challenge: CKRecord, closure: @escaping (CKRecord.ID?, Error?) -> ()) {
        publicDB.delete(withRecordID: challenge.recordID, completionHandler: { recordID, error in
            guard let recordID = recordID, error == nil else {
                closure(nil, error)
                return
            }
            print("challenged deleted: \(recordID)\n\n")
            closure(recordID, error)
        })
    }
    
    
    func respondToChallenge(challenge: CKRecord, accepted: Bool, closure: @escaping (CKRecord?, Error?) -> ()) {
        challenge[Constants.ChallengeFields.status] = (accepted ?
                                                        Constants.ChallengeResponses.accepted :
                                                        Constants.ChallengeResponses.declined)
        publicDB.save(challenge, completionHandler: { record, error in
            guard let record = record, error == nil else {
                closure(nil, error)
                return
            }
            print("challenge response sent: \(record)\n\n")
            closure(record, nil)
        })
    }
    
    
    func getCars(closure: @escaping ([CKRecord]?, Error?) -> ()) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: Constants.RecordTypes.car, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil, completionHandler: { records, error in
            guard let records = records, error == nil else {
                closure(nil, error)
                return
            }
            print("retrieved dlc cars: \(records)\n\n")
            closure(records, nil)
        })
    }
    // END OF DATABASE QUERY METHODS
    
    
    // MARK: SUBSCRIPTION REGISTRATION METHODS
    // the user receives a challenge.
    func registerChallengedSubscription(_ closure: (() -> ())? = nil) {
        guard let cloudioWareProfile = self.cloudioWareProfile else { return }
        
        // create the notification that will be delivered.
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "You have a new challenger."
        notificationInfo.shouldBadge = true
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = [Constants.ChallengeFields.status,
                                        Constants.ChallengeFields.challengerTag,
                                        Constants.ChallengeFields.message]
        
        // create the subscription object.
        let uuid: UUID = UUID()
        let identifier = "\(uuid)-challenged"
        let reference = cloudioWareProfile[Constants.CloudioWareProfileFields.userRecordID] as! CKRecord.Reference
        let predicate = NSPredicate(format: "\(Constants.ChallengeFields.challenged) == %@", reference)
        let subscription = CKQuerySubscription(recordType: Constants.RecordTypes.challenge,
                                               predicate: predicate,
                                               subscriptionID: identifier,
                                               options: [CKQuerySubscription.Options.firesOnRecordCreation])
        
        subscription.notificationInfo = notificationInfo
        
        // save the subscription.
        publicDB.save(subscription, completionHandler: ({ returnRecord, error in
            if let error = error {
                print("challenged subscription failed \(error.localizedDescription)")
            } else {
                print("challenged subscription set up")
            }
            closure?()
        }))
    }
    
    
    func registerChallengeResponseSubscription(_ closure: (() -> ())? = nil) {
        guard let cloudioWareProfile = self.cloudioWareProfile else { return }
        
        // create the notification that will be delivered.
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.desiredKeys = [Constants.ChallengeFields.status,
                                        Constants.ChallengeFields.uuid]
        
        // create the subscription object.
        let uuid: UUID = UUID()
        let identifier = "\(uuid)-challenge-response"
        let reference = cloudioWareProfile[Constants.CloudioWareProfileFields.userRecordID] as! CKRecord.Reference
        let predicate = NSPredicate(format: "\(Constants.ChallengeFields.challenger) == %@", reference)
        let subscription = CKQuerySubscription(recordType: Constants.RecordTypes.challenge,
                                               predicate: predicate,
                                               subscriptionID: identifier,
                                               options: [CKQuerySubscription.Options.firesOnRecordUpdate])
        
        subscription.notificationInfo = notificationInfo
        
        // Save subscription
        publicDB.save(subscription, completionHandler: ({ returnRecord, error in
            if let error = error {
                print("challenge response subscription failed \(error.localizedDescription)")
            } else {
                print("challenge response subscription set up")
            }
            closure?()
        }))
    }
    // END OF SUBSCRIPTION REGISTRATION METHODS
}
