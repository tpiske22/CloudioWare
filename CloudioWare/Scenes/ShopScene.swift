//
//  ShopScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/18/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The ShopScene is where the user can spend their gold collected by racing to buy new
 car skins. These skins are pulled from iCloud on app launch.
 */
class ShopScene: SKScene, UITableViewDelegate, UITableViewDataSource {
    
    // top menu.
    let homeButton = SKButtonNode(text: "Home")
    let separator = SKLabelNode(text: "______________")
    var usersGoldLabel: SKLabelNode!
    let goldImage = SKSpriteNode(imageNamed: "Gold")
    
    // table view.
    var shopTableView: ShopTableView!
    var dlcCars: [Garage.Car] = [] {
        didSet { shopTableView.reloadData() }
    }
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // set up UI.
        setupTopBar()
        setupTableView()
        
        // get cars with which to populate the shop.
        dlcCars = Garage.sharedInstance().dlcCars()
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
        
        // set up gold label and image
        usersGoldLabel = SKLabelNode(text: String(CKManager.sharedInstance().cloudioWareProfile![Constants.CloudioWareProfileFields.gold] as! Int))
        usersGoldLabel.fontSize = 20
        goldImage.size = CGSize(width: 30, height: 30)
        updateUserGoldPositioning()
        self.addChild(usersGoldLabel)
        self.addChild(goldImage)
    }
    
    
    private func updateUserGoldPositioning() {
        usersGoldLabel.position = CGPoint(x: self.frame.width - usersGoldLabel.frame.width / 2 - 10,
                                          y: self.frame.height - usersGoldLabel.frame.height / 2 - 20)
        goldImage.position = CGPoint(x: usersGoldLabel.position.x - usersGoldLabel.frame.width / 2 - goldImage.frame.width / 2 - 10,
                                     y: usersGoldLabel.position.y + usersGoldLabel.frame.height / 2)
    }
    
    
    private func setupTableView() {
        shopTableView = ShopTableView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height - 80))
        shopTableView.center = self.convertPoint(toView: CGPoint(x: self.frame.width / 2, y: self.frame.height / 2 - 40))
        shopTableView.rowHeight = 140
        shopTableView.backgroundColor = ColorPalette.secondaryGray
        shopTableView.delegate = self
        shopTableView.dataSource = self
        self.view?.addSubview(shopTableView)
    }
    // END OF UI SETUP HELPERS
    
    
    // MARK: TABLE VIEW DELEGATE METHODS
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dlcCars.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.Nibs.shopTableViewCell, for: indexPath) as! ShopTableViewCell
        let car = dlcCars[indexPath.row]
        
        if let cloudioWareProfile = CKManager.sharedInstance().cloudioWareProfile {
            let ownedCars = cloudioWareProfile[Constants.CloudioWareProfileFields.cars] as! [String]
            cell.alreadyOwned = ownedCars.contains(car.name)
        } else {
            cell.alreadyOwned = false
        }
        cell.car = car
        cell.shopScene = self
        
        return cell
    }
    // END OF TABLE VIEW DELEGATE METHODS
    
    
    // MARK: CELL TAP CALLBACK
    func cellTapped(_ cell: ShopTableViewCell) {
        cell.buyButton.isEnabled = false
        guard let cloudioWareProfile = CKManager.sharedInstance().cloudioWareProfile, let carForSale = cell.car else {
                cell.buyButton.isEnabled = true
                return
        }
        
        // check to see if the user has enough gold to make the purchase.
        let usersGold = cloudioWareProfile[Constants.CloudioWareProfileFields.gold] as! Int
        if usersGold < carForSale.price! {
            presentInsufficientGoldAlert(forCar: carForSale.name) {
                cell.buyButton.isEnabled = true
            }
        } else {
            presentBuyConfirmationAlert(forCar: carForSale.name, closure: { bought in
                if !bought {
                    cell.buyButton.isEnabled = true
                } else {
                    self.buyCar(carForSale, closure: { error in
                        if error != nil {
                            print("error 13: \(error?.localizedDescription ?? "unknown error")")
                            cell.buyButton.isEnabled = true
                            return
                        }
                        DispatchQueue.main.async {
                            self.usersGoldLabel.text = String(cloudioWareProfile[Constants.CloudioWareProfileFields.gold] as! Int)
                            self.updateUserGoldPositioning()
                            self.shopTableView.reloadData()
                        }
                    })
                }
            })
        }
    }
    // END OF CELL TAP CALLBACK
    
    
    // MARK: ALERT METHODS
    private func presentInsufficientGoldAlert(forCar name: String, closure: @escaping () -> ()) {
        let alertViewController = UIAlertController(title: "Not Enough Gold",
                                                    message: "You don't have enough gold to buy the \(name) car right now.", preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Okay",
                                                    style: .default, handler: { action in
            closure()
        }))
        gameViewController.present(alertViewController, animated: true, completion: nil)
    }
    
    
    private func presentBuyConfirmationAlert(forCar name: String, closure: @escaping (Bool) -> ()) {
        let alertViewController = UIAlertController(title: "Buy Car",
                                                    message: "Buy the \(name) car?", preferredStyle: .alert)
        // cancel purchase.
        alertViewController.addAction(UIAlertAction(title: "Nevermind",
                                                    style: .cancel, handler: { action in
            closure(false)
        }))
        // make purhcase.
        alertViewController.addAction(UIAlertAction(title: "Buy",
                                                    style: .default, handler: { action in
            closure(true)
        }))
        gameViewController.present(alertViewController, animated: true, completion: nil)
    }
    // END OF ALERT METHODS
    
    
    // MARK: DATABASE METHODS
    private func buyCar(_ car: Garage.Car, closure: @escaping (Error?) -> ()) {
        let cloudioWareProfile = CKManager.sharedInstance().cloudioWareProfile!
        
        // update user's fields to reflect purchase.
        var usersGold = cloudioWareProfile[Constants.CloudioWareProfileFields.gold] as! Int
        var usersCars = cloudioWareProfile[Constants.CloudioWareProfileFields.cars] as! [String]
        usersGold -= car.price!
        usersCars.append(car.name)
        
        // push updates to iCloud.
        cloudioWareProfile.setValue(usersGold, forKey: Constants.CloudioWareProfileFields.gold)
        cloudioWareProfile.setValue(usersCars, forKey: Constants.CloudioWareProfileFields.cars)
        CKManager.sharedInstance().pushCloudioWareProfileUpdate(closure: { record, error in
            if error != nil {
                closure(error)
            }
            closure(nil)
        })
    }
    // END OF DATABASE METHODS
}
