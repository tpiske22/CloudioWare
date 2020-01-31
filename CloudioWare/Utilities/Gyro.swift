//
//  Gyro.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import CoreMotion

/*
 The Gyro is a singleton used to start and stop the device's gyroscopic sensor for tilt steering.
 */
// https://developer.apple.com/documentation/coremotion/getting_raw_gyroscope_events
class Gyro {
    
    // singleton
    static var instance: Gyro? = nil
    
    let motion = CMMotionManager()
    var motionTimer: Timer? = nil
    var tilt: Double = 0.0
    
    static func sharedInstance() -> Gyro {
        if instance == nil { instance = Gyro() }
        
        return instance!
    }
    
    private init() { }
    
    func startGyros() {
        if motion.isGyroAvailable {
            motion.gyroUpdateInterval = Constants.tickLength / 1000
            motion.startGyroUpdates()
            
            // Configure a timer to fetch the accelerometer data.
            motionTimer = Timer(fire: Date(), interval: Constants.tickLength / 1000, repeats: true, block: { (timer) in
                // Get the gyro data.
                if let data = self.motion.gyroData {
                    self.tilt += data.rotationRate.z
                }
            })
            
            // Add the timer to the current run loop.
            RunLoop.current.add(self.motionTimer!, forMode: .default)
        }
    }

    func stopGyros() {
       if motionTimer != nil {
          motionTimer?.invalidate()
          motionTimer = nil

          motion.stopGyroUpdates()
       }
    }
}
