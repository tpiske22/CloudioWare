//
//  GameScene.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/17/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

/*
 RACE START ROUTINE
 A simple handshake routine must take place before a race can begin.
 
 1) The challenger sends a challenge/invite to another user.
    ) If the challenger exits the lobby scene in some way, the invite is deleted.
 
 2) The challenged sends a response to the challenger.
    ) If the response is "declined", the invite is deleted.
 
 3) The challenger and challenged enter the race scene. The challenger is responsible for setting up the game session in Firebase.
    ) Both the challenger and challenged continually update their presence fields every 2 seconds. If the opponent does not see a presence update in over 10 seconds, the game is abandoned.
 
 4) Upon seeing an initial presence indication from the challenged, the challenger kicks off the race countdown (3, 2, 1, GO!).
 
 5) The challenger and challenged see the race clock at 0 and the race begins.
 
 
 RACE FINISH ROUTINE
 1) When a race finishes regularly, the loser deletes the game session.
 
 2) If a player loses internet connection, they automatically lose.
    ) If a player doesn't get a presence update from their opponent for 8 seconds, they assume their opponent lost connection and declare victory.
    ) In a connection-loss win scenario, the winner deletes the game session.
 */

import SpriteKit
import GameplayKit
import CoreMotion
import CloudKit
import FirebaseDatabase

/*
 The RaceScene is where matches between the user and their opponent are held. When a game ends
 by a win, loss, or forfeit by connection loss, the user will be transitioned to the ResultsScene.
 */
class RaceScene: SKScene {
        
    enum ControlScheme {
        static let tilt = "tilt"
        static let touch = "touch"
    }
    
    // race start handshake and state.
    var isChallenger: Bool!
    var isOpponentReady: Bool = false {
        didSet {
            if isOpponentReady {
                pushCarType()
                if isChallenger {
                    kickoffCountdown()
                }
            }
        }
    }
    var raceCountdown: Int = 4 {
        didSet {
            if raceCountdown < 4    {
                setRaceStatusLabel(to: "\(raceCountdown)")
                if UserDefaults.hapticsOn == "true" {
                    countdownFeedbackGenerator?.notificationOccurred(.success)
                }
            }
            if raceCountdown == 0 {
                raceStarted = true
                countdownFeedbackGenerator = nil
            }
        }
    }
    var raceStarted: Bool = false {
        didSet {
            if raceStarted {
                setRaceStatusLabel(to: "GO!")
                let fade = SKAction.fadeAlpha(to: 0.0, duration: 2.0)
                raceStatusLabel.run(fade)
                
                // reset tilt at the start of a race.
                Gyro.sharedInstance().tilt = 0
                
                // start the collision haptic generator.
                if UserDefaults.hapticsOn == "true" {
                    collisionFeedbackGenerator?.prepare()
                }
            }
        }
    }
    lazy var kickoffQueue = DispatchQueue(label: "kickoff")
    var presence: Int = 0
    var level: Int = 1 {
        didSet {
            updateLevel()
            if level > 3 {
                wonRace = true
                pushGameOver()
            }
        }
    }
    var roadStrips: [SKSpriteNode] = []
    var mudPits: [SKSpriteNode] = []
    var wonRace: Bool = false
    
    // status label.
    var raceStatusLabel: SKLabelNode!
    
    // racecar nodes.
    var car: SKSpriteNode!
    var opponentCar = SKSpriteNode(imageNamed: "light blue")
    var opponentCarType: String! {
        didSet {
            setOpponentCar()
        }
    }
    
    // car handling via tilt controls.
    var tiltRotation: Double = 0
    
    // car speeds.
    var carSpeedIndex: Int = 1
    let carSpeeds: [Double] = [0, 1, 2, 3]
    
    // for timekeeping.
    var lastTick = Date()
    var pushPresenceTicker: Int = 0 {
        didSet {
            if pushPresenceTicker >= 120 && !GameViewController.isOfflineRaceTesting {
                pushPresence()
                pushPresenceTicker = 0
            }
        }
    }
    var pushCarStateTicker: Int = 0 {
        didSet {
            if pushCarStateTicker >= 4 && !GameViewController.isOfflineRaceTesting {
                pushCarState()
                pushCarStateTicker = 0
            }
        }
    }
    var opponentPresenceTimeoutTicker: Int = 0 {
        didSet {
            if opponentPresenceTimeoutTicker >= (10 * 60) && !GameViewController.isOfflineRaceTesting {
                wonRace = true
                exitGame(dueToConnectionFailure: true)
            }
        }
    }
    
    // for some haptic feedback.
    lazy var countdownFeedbackGenerator: UINotificationFeedbackGenerator? = UINotificationFeedbackGenerator()
    lazy var collisionFeedbackGenerator: UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator()
    var carCollided: Bool = false {
        didSet {
            if carCollided && (oldValue != carCollided) && (UserDefaults.hapticsOn == "true") {
                collisionFeedbackGenerator?.impactOccurred()
            }
        }
    }
    
    // for game hosting.
    var challenge: CKRecord!
    var uuid: String!
    var realtimeDB: DatabaseReference!
    
    // for scene direction.
    var gameViewController: GameViewController!
    
    
    // MARK: LIFECYCLE METHODS
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // add touch acceleration and deceleration.
        let accelerateSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipePedal(_:)))
        let decelerateSwipe = UISwipeGestureRecognizer(target: self, action: #selector(swipePedal(_:)))
        accelerateSwipe.direction = .up
        decelerateSwipe.direction = .down
        self.view?.addGestureRecognizer(accelerateSwipe)
        self.view?.addGestureRecognizer(decelerateSwipe)
        
        // start gyroscope for steering.
        if UserDefaults.controlScheme == ControlScheme.tilt {
            Gyro.sharedInstance().startGyros()
        
        // add touch steering.
        // https://stackoverflow.com/questions/33637220/how-to-use-pan-gesture-and-a-swipe-gesture-alternatively-on-the-same-view
        } else {
            let panSteering = UIPanGestureRecognizer(target: self, action: #selector(panSteering(_:)))
            panSteering.require(toFail: accelerateSwipe)
            panSteering.require(toFail: decelerateSwipe)
            self.view?.addGestureRecognizer(panSteering)
        }
        
        // prepare the feedback generator for the countdown.
        if UserDefaults.hapticsOn == "true" {
            countdownFeedbackGenerator?.prepare()
        }
        
        // set up UI.
        setupCars()
        setRaceStatusLabel(to: "Start Your Engines", initialize: true)
        self.backgroundColor = ColorPalette.grassGreen
            
        if !GameViewController.isOfflineRaceTesting {
            // get uuid.
            uuid = challenge[Constants.ChallengeFields.uuid] as? String
            
            // set up firebase.
            realtimeDB = Database.database().reference()
            addAllListeners()
            if isChallenger {
                createGameSession()
            }
            
            // monitor connectivity changes.
            NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                                   name: Constants.NotificationNames.connectivityChanged, object: nil)
        } else {
            DispatchQueue.main.async {
                self.raceCountdown = 0
            }
        }
        level = 1
    }
    // END OF LIFECYCLE METHODS
    
    
    // MARK: UI SETUP METHODS
    private func setupCars() {
        // set your car color.
        if !GameViewController.isOfflineRaceTesting {
            let carInfo = Garage.sharedInstance().cars.first(where: { $0.name == UserDefaults.car })
            car = SKSpriteNode(texture: SKTexture(image: carInfo!.image))
        } else {
            car = SKSpriteNode(imageNamed: "light blue")
        }
        
        // resize your car.
        let sizeRatio = car.frame.height / car.frame.width
        car.size = CGSize(width: 20, height: 20 * sizeRatio)
        
        // position.
        if isChallenger {
            car.position = CGPoint(x: self.frame.width / 2 - 20, y: 0)
            opponentCar.position = CGPoint(x: self.frame.width / 2 + 20, y: 0)
        } else {
            car.position = CGPoint(x: self.frame.width / 2 + 20, y: 0)
            opponentCar.position = CGPoint(x: self.frame.width / 2 - 20, y: 0)
        }
        opponentCar.alpha = 0.0
        self.addChild(car)
        self.addChild(opponentCar)
    }
    
    
    private func setOpponentCar() {
        // set your car color.
        let carInfo = Garage.sharedInstance().cars.first(where: { $0.name == opponentCarType })
        opponentCar.texture = SKTexture(image: carInfo!.image)
        
        // resize your car.
        let sizeRatio = opponentCar.frame.height / opponentCar.frame.width
        opponentCar.size = CGSize(width: 20, height: 20 * sizeRatio)
        
        // fade in.
        let fade = SKAction.fadeAlpha(to: 0.5, duration: 1.0)
        opponentCar.run(fade)
    }
    
    
    private func setRaceStatusLabel(to status: String, initialize: Bool = false) {
        DispatchQueue.main.async {
            if initialize {
                self.raceStatusLabel = SKLabelNode()
                self.raceStatusLabel.fontSize = 40
                self.raceStatusLabel.fontName = "HelveticaNeue-Thin"
                self.raceStatusLabel.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
                self.addChild(self.raceStatusLabel)
            }
            self.raceStatusLabel.text = status
        }
    }
    // END OF UI SETUP METHODS
    
    
    // MARK: FRAME UPDATE METHODS
    override func update(_ currentTime: TimeInterval) {
        if abs(lastTick.timeIntervalSinceNow * 1000) >= Constants.tickLength {
            tick()
        }
    }
    
    
    private func tick() {
        if raceStarted {
            updateCarState()
            lastTick = Date()
            pushCarStateTicker += 1
        }
        pushPresenceTicker += 1
        if !wonRace { opponentPresenceTimeoutTicker += 1 }
    }
    
    
    private func updateCarState() {
        
        // move steering wheel.
        if ControlScheme.tilt == UserDefaults.controlScheme {
            updateCarRotationByTilt()
        }
        
        // is the car on the road? Default to no.
        var carSpeed: Double = min(0.5, carSpeeds[carSpeedIndex])
        for roadStrip in roadStrips {
            if roadStrip.intersects(car) {
                carSpeed = carSpeeds[carSpeedIndex]
                break
            }
        }
        // is the car in a mud pit?
        for mudPit in mudPits {
            if mudPit.intersects(car) {
                carSpeedIndex = min(1, carSpeedIndex)
                break
            }
        }
        // move the car.
        let rotationAngle = car.zRotation
        let xVelocity = CGFloat(carSpeed) * sin(-rotationAngle)
        let yVelocity = CGFloat(carSpeed) * cos( rotationAngle)
        car.position.x = max(min(car.position.x + xVelocity, self.frame.width - car.frame.width / 2), car.frame.width / 2)
        car.position.y = max(car.position.y + yVelocity, 0)
        
        // detect a wall collision
        carCollided = (car.position.x == self.frame.width - car.frame.width / 2) ||
            (car.position.x == car.frame.width / 2) ||
            (car.position.y == 0)
        
        // wrap in the y directions for a level change.
        if car.position.y > self.view?.frame.size.height ?? 0 {
            car.position.y = 0
            level += 1
        }
    }
    
    
    private func updateCarRotationByTilt() {
        tiltRotation = Gyro.sharedInstance().tilt / 20
        let rotateAction = SKAction.rotate(toAngle: CGFloat(tiltRotation), duration: 0)
        car.run(rotateAction)
    }
    private func updateCarRotationByPan(translation: CGPoint) {
        let rotation = -translation.x / 100
        let rotationAction = SKAction.rotate(byAngle: rotation, duration: 0)
        car.run(rotationAction)
    }
    
    
    private func constrainCarMovement(movement: Double, constraint: Double) -> Double {
        if movement < 0     { return max(movement, -constraint) }
        else                { return min(movement, constraint)  }
    }
    
    
    func exitGame(dueToConnectionFailure: Bool = false) {
        if dueToConnectionFailure || !self.wonRace {
            deleteGameSession()
        }
        DispatchQueue.main.async {
            self.gameViewController.presentResultsScene(wonRace: self.wonRace,
                                                        dueToConnectionFailure: dueToConnectionFailure)
        }
    }
    // END OF FRAME UPDATE METHODS
    
    
    // MARK: GESTURE METHODS
    @objc func panSteering(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        updateCarRotationByPan(translation: translation)
        
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
    
    
    @objc func swipePedal(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .up {
            carSpeedIndex = min(carSpeedIndex + 1, carSpeeds.count - 1)
        } else if sender.direction == .down {
            carSpeedIndex = max(carSpeedIndex - 1, 0)
        }
    }
    
    
    // some reference stuff from https://www.appcoda.com/spritekit-introduction/.
//    @objc func didTap(_ sender: UIGestureRecognizer) {
//        let viewLocation = sender.location(in: self.view)
//        let sceneLocation = self.convertPoint(fromView: viewLocation)
//
//        if car.contains(sceneLocation) {
//            print("you touched me :(")
//        } else {
//            let moveAction = SKAction.moveBy(x: sceneLocation.x - car.position.x, y: sceneLocation.y - car.position.y, duration: 1)
//            let moveActionBackwards = moveAction.reversed()
//            let moveSequence = SKAction.sequence([moveAction, moveActionBackwards])
//            let moveSequenceRepeated = SKAction.repeat(moveSequence, count: 3)
//            car.run(moveSequenceRepeated, completion: { () -> () in
//                print("done")
//            })
//        }
//    }
    // END OF GESTURE METHODS
    
    
    // MARK: CONNECTIVITY SELECTOR
    @objc func connectivityChanged() {
        gameViewController.presentResultsScene(wonRace: false, dueToConnectionFailure: true)
    }
    // END OF CONNECTIVITY SELECTOR
}

