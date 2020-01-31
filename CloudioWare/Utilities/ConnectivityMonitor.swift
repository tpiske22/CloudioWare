//
//  ConnectivityMonitor.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/21/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import Network
import Foundation

/*
 The ConnectivityMonitor is a singleton that monitors for internet connectivity changes.
 When one occurs, it posts a connectivity changed notification.
 */
// https://www.hackingwithswift.com/example-code/networking/how-to-check-for-internet-connectivity-using-nwpathmonitor
class ConnectivityMonitor {
    
    // internet connectivity monitor and monitoring queue.
    let monitor = NWPathMonitor()
    let monitoringQueue = DispatchQueue(label: "monitor")
    
    // online status.
    var appOnline: Bool = false {
        didSet {
            if oldValue != appOnline {
                NotificationCenter.default.post(name: Constants.NotificationNames.connectivityChanged, object: nil)
            }
        }
    }
    
    static var instance: ConnectivityMonitor? = nil
    
    static func sharedInstance() -> ConnectivityMonitor {
        if instance == nil {
            instance = ConnectivityMonitor()
        }
        return instance!
    }
    
    private init() { }
    
    func startMonitoringConnectivity() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                if path.status == .satisfied {
                    self.appOnline = true
                } else {
                    self.appOnline = false
                }
            }
        }
        monitor.start(queue: monitoringQueue)
    }
}
