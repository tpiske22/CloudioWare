//
//  AppDelegate.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    let splashDuration: TimeInterval = 1.0
    
    var window: UIWindow?
        
    // MARK: LIFECYCLE METHODS
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // set up firebase.
        FirebaseApp.configure()
        
        // setup connectivity monitor.
        ConnectivityMonitor.sharedInstance().startMonitoringConnectivity()
        
        // Request authorization for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("error 9: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        // set the UN center to receive notifications in all cases.
        UNUserNotificationCenter.current().delegate = self
        
        // if we're launching from a push notification, get the notification info.
        if let notification = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: AnyObject] {
            let aps = notification["aps"] as! [String : AnyObject]
            print("APS: \(aps)")
        }
        
        // remove the badge and clear notifications upon opening the app.
        application.applicationIconBadgeNumber = 0
//        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
//        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: )
//        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
//            settings.badgeSetting false
//        })
        
        Thread.sleep(forTimeInterval: splashDuration)
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        CKManager.sharedInstance().setOnlineStatus(isOnline: true, closure: { _, _ in })
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        Gyro.sharedInstance().stopGyros()
        CKManager.sharedInstance().setOnlineStatus(isOnline: false, closure: { _, _ in })
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Gyro.sharedInstance().stopGyros()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        CKManager.sharedInstance().setOnlineStatus(isOnline: false, closure: { _, _ in })
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: NOTIFICATION METHODS
    // call when application is open and a notification is received.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    
    // push notification received.
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        // get the aps notification data.
        let aps = userInfo["aps"] as! [String : AnyObject]
        
        // send app-wide notifications about the event.
        let contentAvailable = aps["content-available"] as! Int
        if contentAvailable == 1 {
            print(userInfo)
            let cloudKitInfo = userInfo["ck"] as! [String : AnyObject]
            //let recordID = (cloudKitInfo["qry"] as! [String: AnyObject])["rid"] as! String
            let field = (cloudKitInfo["qry"] as! [String : AnyObject])["af"] as! [String : AnyObject]
            let response = field[Constants.ChallengeFields.status] as! String
                
            // check that the notification is for a (silent) challenge response.
            if response != Constants.ChallengeResponses.pending {
                
                // send the challenge response's uuid so the challenger can verify the challenger response coming in.
                let uuid = field[Constants.ChallengeFields.uuid] as! String
                let userInfoDictionary: [String : String] = [Constants.ChallengeFields.uuid : uuid]
                if response == Constants.ChallengeResponses.accepted {
                    NotificationCenter.default.post(name: Constants.NotificationNames.challengeAccepted,
                                                    object: nil, userInfo: userInfoDictionary)
                    
                } else if response == Constants.ChallengeResponses.declined {
                    NotificationCenter.default.post(name: Constants.NotificationNames.challengeDeclined,
                                                    object: nil, userInfo: userInfoDictionary)
                }
            }
            
            completionHandler(.newData)
        } else {
            completionHandler(.noData)
        }
    }
    
    
    // from a launch by a new challenge push notification, present the invite scene.
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        NotificationCenter.default.post(name: Constants.NotificationNames.challengeReceived,
                                        object: nil, userInfo: nil)
    }
    // END OF NOTIFICATION METHODS
}

