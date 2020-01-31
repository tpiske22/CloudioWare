//
//  Garage+Cache.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/26/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import UIKit
import CloudKit

/*
 The Garage is a singleton used to download and store car names, prices, and images.
 */
class Garage {
    
    struct Car {
        let name: String
        let price: Int?
        let image: UIImage
    }
    var cars: [Car] = []
    
    static var instance: Garage? = nil
    
    
    // MARK: INITIALIZERS
    static func sharedInstance() -> Garage {
        if instance == nil {
            instance = Garage()
        }
        return instance!
    }
    
    private init() {
        let baseCars = ["light blue", "brown", "green", "pink"]
        for car in baseCars {
            cars.append(Car(name: car, price: nil, image: UIImage(imageLiteralResourceName: car)))
        }
    }
    // END OF INITIALIZERS
    
    
    // MARK: DATABASE METHODS
    func getDLCCars(closure: @escaping (Error?) -> ()) {
        CKManager.sharedInstance().getCars(closure: { records, error in
            guard let records = records, error == nil else {
                closure(error)
                return
            }
            for record in records {
                let name = record[Constants.CarFields.name] as! String
                let price = record[Constants.CarFields.price] as! Int
                if let cachedData = Cache.cars.object(forKey: NSString(string: name)),
                    let image = UIImage(data: cachedData as Data) {
                    
                    self.cars.append(Car(name: name, price: price, image: image))
                    print("loaded \(name) car from cache")
                    
                } else if let asset = record[Constants.CarFields.image] as? CKAsset,
                    let data = NSData(contentsOf: asset.fileURL!),
                    let image = UIImage(data: data as Data) {
                    
                    Cache.cars.setObject(data, forKey: NSString(string: name))
                    self.cars.append(Car(name: name, price: price, image: image))
                    print("loaded \(name) car from iCloud")
                }
            }
            closure(nil)
        })
    }
    // END OF DATABASE METHODS
    
    
    // MARK: OTHER HELPERS
    // dlc stands for downloadable content.
    func dlcCars() -> [Car] {
        return cars.filter({ $0.price != nil }).sorted(by: { $0.price! < $1.price! })
    }
    // END OF OTHER HELPERS
}


// cache car images so we're not loading images from iCloud every launch.
struct Cache {
    static let cars = NSCache<NSString, NSData>()
}
