//
//  SKButton.swift
//  CloudioWare
//
//  Created by Taylor Piske on 11/20/19.
//  Copyright © 2019 Taylor Piske. All rights reserved.
//

import SpriteKit

/*
 The SKButtonNode is an SKLabelNode with button functionality.
 When clicked, it'll flash the selectedColor and run its action.
 */
class SKButtonNode: SKLabelNode {
    
    private var parentScene: SKScene!
    private var action: (() -> ())? = nil
    var isEnabled: Bool = true {
        didSet {
            if isEnabled {
                fontColor = idleColor
            } else {
                fontColor = idleColor.withAlphaComponent(0.5)
            }
        }
    }
    var idleColor: UIColor! {
        didSet { fontColor = idleColor }
    }
    var selectedColor: UIColor!
    
    
    // MARK: INITIALIZERS
    init(text: String, action: (() -> ())? = nil) {
        super.init(fontNamed: Constants.fontName)
        self.text = text
        self.fontSize = 32
        self.idleColor = ColorPalette.white
        self.selectedColor = ColorPalette.gold
        
        self.isUserInteractionEnabled = true
        self.action = action
    }
    
    
    override init() {
        super.init()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    // END OF INITIALIZERS
    
    
    // MARK: GESTURE METHODS
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if isEnabled {
            guard let touch = touches.first else { return }
            colorFont(touch: touch)
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        if isEnabled {
            guard let touch = touches.first else { return }
            colorFont(touch: touch)
        }
    }
    
    
    private func colorFont(touch: UITouch) {
        if parentScene == nil { parentScene = self.parent as? SKScene }
        
        let viewLocation = touch.location(in: parentScene.view)
        let sceneLocation = parentScene.convertPoint(fromView: viewLocation)
        
        if self.contains(sceneLocation) {
            self.fontColor = selectedColor
        } else {
            self.fontColor = idleColor
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        if isEnabled {
            guard let touch = touches.first else { return }
            let viewLocation = touch.location(in: parentScene.view)
            let sceneLocation = parentScene.convertPoint(fromView: viewLocation)
            
            if self.contains(sceneLocation) {
                self.fontColor = idleColor
                action?()
            }
        }
    }
    // END OF GESTURE METHODS
    
    
    // MARK: GETTERS AND SETTERS
    func setAction(action: @escaping () -> ()) {
        self.action = action
    }
    // END OF GETTERS AND SETTERS
}

