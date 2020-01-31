//
//  RaceScene+Levels.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/28/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The levels RaceScene extension includes logic that instantiates level objects and places them in the RaceScene.
 */
extension RaceScene {
    
    func updateLevel() {
        self.removeAllChildren()
        roadStrips.removeAll()
        mudPits.removeAll()
        
        // create road strips and other level things.
        if level == 1       { createLevelOne() }
        else if level == 2  { createLevelTwo() }
        else if level == 3  { createLevelThree() }
        
        // re-add cars.
        self.addChild(car)
        self.addChild(opponentCar)
    }
    
    
    private func createLevelOne() {
        // PAVE ROADS.
        // entry strip.
        let roadStrip1 = createRoadStrip(type: "roadUp")
        roadStrip1.position = CGPoint(x: self.frame.width / 2,
                                      y: 0 + roadStrip1.frame.height / 2)
        self.addChild(roadStrip1)
        roadStrips.append(roadStrip1)
        
        // lower merge junction.
        let roadStrip2 = createRoadStrip(type: "junction1")
        roadStrip2.position = CGPoint(x: self.frame.width / 2,
                                      y: roadStrip1.frame.height + roadStrip2.frame.height / 2)
        self.addChild(roadStrip2)
        roadStrips.append(roadStrip2)
        
        // lower left upward junction.
        let roadStrip3 = createRoadStrip(type: "junction2")
        roadStrip3.position = CGPoint(x: roadStrip2.position.x - roadStrip2.frame.width / 2 - roadStrip3.frame.width / 2,
                                      y: roadStrip2.position.y)
        self.addChild(roadStrip3)
        roadStrips.append(roadStrip3)
        
        // lower right upward junction.
        let roadStrip4 = createRoadStrip(type: "junction3")
        roadStrip4.position = CGPoint(x: roadStrip2.position.x + roadStrip2.frame.width / 2 + roadStrip4.frame.width / 2,
                                      y: roadStrip2.position.y)
        self.addChild(roadStrip4)
        roadStrips.append(roadStrip4)
        
        // left long road strip.
        let roadStrip5 = createRoadStrip(type: "roadUp")
        roadStrip5.position = CGPoint(x: roadStrip3.position.x,
                                      y: roadStrip3.position.y + roadStrip3.frame.height / 2 + roadStrip5.frame.height / 2)
        self.addChild(roadStrip5)
        roadStrips.append(roadStrip5)
        
        // right long road strip.
        let roadStrip6 = createRoadStrip(type: "roadUp")
        roadStrip6.position = CGPoint(x: roadStrip4.position.x,
                                      y: roadStrip4.position.y + roadStrip4.frame.height / 2 + roadStrip6.frame.height / 2)
        self.addChild(roadStrip6)
        roadStrips.append(roadStrip6)
        
        // upper left rightward junction.
        let roadStrip7 = createRoadStrip(type: "junction5")
        roadStrip7.position = CGPoint(x: roadStrip5.position.x,
                                      y: roadStrip5.position.y + roadStrip5.frame.height / 2 + roadStrip7.frame.height / 2)
        self.addChild(roadStrip7)
        roadStrips.append(roadStrip7)
        
        // upper right leftward junction.
        let roadStrip8 = createRoadStrip(type: "junction6")
        roadStrip8.position = CGPoint(x: roadStrip6.position.x,
                                      y: roadStrip6.position.y + roadStrip6.frame.height / 2 + roadStrip8.frame.height / 2)
        self.addChild(roadStrip8)
        roadStrips.append(roadStrip8)
        
        // upper merge junction.
        let roadStrip9 = createRoadStrip(type: "junction4")
        roadStrip9.position = CGPoint(x: roadStrip2.position.x,
                                      y: roadStrip8.position.y)
        self.addChild(roadStrip9)
        roadStrips.append(roadStrip9)
        
        // exit strip.
        let roadStrip10 = createRoadStrip(type: "roadUp")
        roadStrip10.position = CGPoint(x: roadStrip9.position.x,
                                       y: roadStrip9.position.y + roadStrip9.frame.height / 2 + roadStrip10.frame.height / 2)
        self.addChild(roadStrip10)
        roadStrips.append(roadStrip10)
        
        // overflow exist strip for bigger phones.
        let roadStrip11 = createRoadStrip(type: "roadUp")
        roadStrip11.position = CGPoint(x: roadStrip10.position.x,
                                       y: roadStrip10.position.y + roadStrip10.frame.height / 2 + roadStrip11.frame.height / 2)
        self.addChild(roadStrip11)
        roadStrips.append(roadStrip11)
        
        
        // ADD MUD.
        // lower left.
        let mudPit1 = createMudPit()
        mudPit1.position = CGPoint(x: roadStrip5.position.x + roadStrip5.frame.width / 4,
                                   y: roadStrip5.position.y - roadStrip5.frame.height / 4)
        self.addChild(mudPit1)
        mudPits.append(mudPit1)
        
        // lower right.
        let mudPit2 = createMudPit()
        mudPit2.position = CGPoint(x: roadStrip6.position.x + roadStrip6.frame.width / 4,
                                   y: roadStrip6.position.y - roadStrip6.frame.height / 4)
        self.addChild(mudPit2)
        mudPits.append(mudPit2)
        
        // upper left.
        let mudPit3 = createMudPit()
        mudPit3.position = CGPoint(x: roadStrip5.position.x - roadStrip5.frame.width / 4,
                                   y: roadStrip5.position.y + roadStrip5.frame.height / 4)
        self.addChild(mudPit3)
        mudPits.append(mudPit3)
        
        // upper right.
        let mudPit4 = createMudPit()
        mudPit4.position = CGPoint(x: roadStrip6.position.x - roadStrip6.frame.width / 4,
                                   y: roadStrip6.position.y + roadStrip6.frame.height / 4)
        self.addChild(mudPit4)
        mudPits.append(mudPit4)
        
        // exit pit.
        let mudPit5 = createMudPit()
        mudPit5.position = CGPoint(x: roadStrip10.position.x - roadStrip10.frame.width / 4,
                                   y: roadStrip10.position.y)
        self.addChild(mudPit5)
        mudPits.append(mudPit5)
    }
    
    
    private func createLevelTwo() {
        // entry strip.
        let roadStrip1 = createRoadStrip(type: "junction6")
        roadStrip1.position = CGPoint(x: self.frame.width / 2,
                                      y: 0 + roadStrip1.frame.height / 2)
        self.addChild(roadStrip1)
        roadStrips.append(roadStrip1)
        
        // lower left upward junction.
        let roadStrip2 = createRoadStrip(type: "junction2")
        roadStrip2.position = CGPoint(x: self.frame.width / 2 - roadStrip1.frame.width / 2 - roadStrip2.frame.width / 2,
                                      y: roadStrip1.position.y)
        self.addChild(roadStrip2)
        roadStrips.append(roadStrip2)
        
        // lower left long strip.
        let roadStrip3 = createRoadStrip(type: "roadUp")
        roadStrip3.position = CGPoint(x: roadStrip2.position.x,
                                      y: roadStrip2.position.y + roadStrip2.frame.height / 2 + roadStrip3.frame.height / 2)
        self.addChild(roadStrip3)
        roadStrips.append(roadStrip3)
        
        // middle rightward junction.
        let roadStrip4 = createRoadStrip(type: "junction5")
        roadStrip4.position = CGPoint(x: roadStrip3.position.x,
                                      y: roadStrip3.position.y + roadStrip3.frame.height / 2 + roadStrip4.frame.height / 2)
        self.addChild(roadStrip4)
        roadStrips.append(roadStrip4)
        
        // middle sideways strip.
        let roadStrip5 = createRoadStrip(type: "roadSideShort")
        roadStrip5.position = CGPoint(x: roadStrip1.position.x,
                                      y: roadStrip4.position.y)
        self.addChild(roadStrip5)
        roadStrips.append(roadStrip5)
        
        // middle upward junction.
        let roadStrip6 = createRoadStrip(type: "junction3")
        roadStrip6.position = CGPoint(x: roadStrip5.position.x + roadStrip5.frame.width / 2 + roadStrip6.frame.width / 2,
                                      y: roadStrip5.position.y)
        self.addChild(roadStrip6)
        roadStrips.append(roadStrip6)
        
        // upper right long strip.
        let roadStrip7 = createRoadStrip(type: "roadUp")
        roadStrip7.position = CGPoint(x: roadStrip6.position.x,
                                      y: roadStrip6.position.y + roadStrip6.frame.height / 2 + roadStrip7.frame.height / 2)
        self.addChild(roadStrip7)
        roadStrips.append(roadStrip7)
        
        // upper leftward junction.
        let roadStrip8 = createRoadStrip(type: "junction6")
        roadStrip8.position = CGPoint(x: roadStrip7.position.x,
                                      y: roadStrip7.position.y + roadStrip7.frame.height / 2 + roadStrip8.frame.height / 2)
        self.addChild(roadStrip8)
        roadStrips.append(roadStrip8)
        
        // upper upward junction.
        let roadStrip9 = createRoadStrip(type: "junction2")
        roadStrip9.position = CGPoint(x: roadStrip1.position.x,
                                      y: roadStrip8.position.y)
        self.addChild(roadStrip9)
        roadStrips.append(roadStrip9)
        
        // exit strip.
        let roadStrip10 = createRoadStrip(type: "roadUp")
        roadStrip10.position = CGPoint(x: roadStrip1.position.x,
                                       y: roadStrip9.position.y + roadStrip9.frame.height / 2 + roadStrip10.frame.height / 2)
        self.addChild(roadStrip10)
        roadStrips.append(roadStrip10)
        
        
        // ADD MUD.
        // first turn.
        let mudPit1 = createMudPit()
        mudPit1.position = CGPoint(x: roadStrip5.position.x - roadStrip5.frame.width / 4,
                                   y: roadStrip5.position.y - roadStrip5.frame.height / 4)
        self.addChild(mudPit1)
        roadStrips.append(mudPit1)
        
        // last long strip lower.
        let mudPit2 = createMudPit()
        mudPit2.position = CGPoint(x: roadStrip7.position.x - roadStrip7.frame.width / 4,
                                   y: roadStrip7.position.y - roadStrip7.frame.height / 4)
        self.addChild(mudPit2)
        roadStrips.append(mudPit2)
        
        // last long strip middle.
        let mudPit3 = createMudPit()
        mudPit3.position = CGPoint(x: roadStrip7.position.x - roadStrip7.frame.width / 4,
                                   y: roadStrip7.position.y)
        self.addChild(mudPit3)
        roadStrips.append(mudPit3)
        
        // last long strip upper.
        let mudPit4 = createMudPit()
        mudPit4.position = CGPoint(x: roadStrip7.position.x - roadStrip7.frame.width / 4,
                                   y: roadStrip7.position.y + roadStrip7.frame.height / 4)
        self.addChild(mudPit4)
        roadStrips.append(mudPit4)
        
        // last long strip turn.
        let mudPit5 = createMudPit()
        mudPit5.position = CGPoint(x: roadStrip9.position.x + roadStrip9.frame.width / 4,
                                   y: roadStrip9.position.y)
        self.addChild(mudPit5)
        roadStrips.append(mudPit5)
    }
    
    
    private func createLevelThree() {
        // long strip.
        let roadStrip1 = createRoadStrip(type: "roadUp")
        roadStrip1.position = CGPoint(x: self.frame.width / 2,
                                      y: 0 + roadStrip1.frame.height / 2)
        self.addChild(roadStrip1)
        roadStrips.append(roadStrip1)
        
        // long strip.
        let roadStrip2 = createRoadStrip(type: "roadUp")
        roadStrip2.position = CGPoint(x: self.frame.width / 2,
                                      y: roadStrip1.position.y + roadStrip1.frame.height / 2 + roadStrip2.frame.height / 2)
        self.addChild(roadStrip2)
        roadStrips.append(roadStrip2)
        
        // long strip.
        let roadStrip3 = createRoadStrip(type: "roadUp")
        roadStrip3.position = CGPoint(x: self.frame.width / 2,
                                      y: roadStrip2.position.y + roadStrip2.frame.height / 2 + roadStrip3.frame.height / 2)
        self.addChild(roadStrip3)
        roadStrips.append(roadStrip3)
        
        // long strip.
        let roadStrip4 = createRoadStrip(type: "roadUp")
        roadStrip4.position = CGPoint(x: self.frame.width / 2,
                                      y: roadStrip3.position.y + roadStrip3.frame.height / 2 + roadStrip4.frame.height / 2)
        self.addChild(roadStrip4)
        roadStrips.append(roadStrip4)
        
        // long strip.
        let roadStrip5 = createRoadStrip(type: "roadUp")
        roadStrip5.position = CGPoint(x: self.frame.width / 2,
                                      y: roadStrip4.position.y + roadStrip4.frame.height / 2 + roadStrip5.frame.height / 2)
        self.addChild(roadStrip5)
        roadStrips.append(roadStrip5)
        
        
        // ADD MUD.
        // left.
        let mudPit1 = createMudPit()
        mudPit1.position = CGPoint(x: roadStrip1.position.x - roadStrip1.frame.width / 4,
                                   y: roadStrip1.position.y)
        self.addChild(mudPit1)
        roadStrips.append(mudPit1)
        
        // right.
        let mudPit2 = createMudPit()
        mudPit2.position = CGPoint(x: roadStrip2.position.x + roadStrip2.frame.width / 4,
                                   y: roadStrip2.position.y)
        self.addChild(mudPit2)
        roadStrips.append(mudPit2)
        
        // left.
        let mudPit3 = createMudPit()
        mudPit3.position = CGPoint(x: roadStrip3.position.x - roadStrip3.frame.width / 4,
                                   y: roadStrip3.position.y)
        self.addChild(mudPit3)
        roadStrips.append(mudPit3)
        
        // right.
        let mudPit4 = createMudPit()
        mudPit4.position = CGPoint(x: roadStrip4.position.x + roadStrip4.frame.width / 4,
                                   y: roadStrip4.position.y)
        self.addChild(mudPit4)
        roadStrips.append(mudPit4)
        
        // left.
        let mudPit5 = createMudPit()
        mudPit5.position = CGPoint(x: roadStrip5.position.x - roadStrip5.frame.width / 4,
                                   y: roadStrip5.position.y)
        self.addChild(mudPit5)
        roadStrips.append(mudPit5)
        
        
        // FINISH LINE.
        let finishLine = createFinishLine()
        finishLine.position = CGPoint(x: roadStrip5.position.x,
                                      y: self.frame.height - finishLine.frame.height / 2)
        self.addChild(finishLine)
    }
    
    
    private func createRoadStrip(type: String) -> SKSpriteNode {
        let roadStrip = SKSpriteNode(imageNamed: "\(type)")
        let sizeRatio: Double = 165 / 231 // width / height
        
        // set size by road direction.
        if type == "roadUp" {
            roadStrip.size = CGSize(width: 150 * sizeRatio, height: 150)
        } else if type == "roadSide" {
            roadStrip.size = CGSize(width: 150, height: 150 * sizeRatio)
        } else if type.contains("junction") || type == "roadSideShort" {
            roadStrip.size = CGSize(width: 150 * sizeRatio, height: 150 * sizeRatio)
        }
        
        return roadStrip
    }
    
    
    private func createMudPit() -> SKSpriteNode {
        let mudPit = SKSpriteNode(imageNamed: "mudPit")
        mudPit.size = CGSize(width: 35, height: 35)
        
        return mudPit
    }
    
    
    private func createFinishLine() -> SKSpriteNode {
        let finishLine = SKSpriteNode(imageNamed: "finishLine")
        let roadSizeRatio: CGFloat = 165 / 231 // width / height
        let finishLineSizeRatio: CGFloat = finishLine.frame.height / finishLine.frame.width
        finishLine.size = CGSize(width: 150 * roadSizeRatio, height: 150 * roadSizeRatio * finishLineSizeRatio)
        
        return finishLine
    }
}
