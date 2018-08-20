//
//  SplashScene.swift
//  Breakout
//
//  Created by MPP on 15/8/18.
//  Copyright © 2018 Matthew Purcell. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {

    var touchedInsideButton = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if touchedNode.name == "buttonNode" {
            
            touchedInsideButton = true
            let buttonNode = touchedNode as! SKSpriteNode
            buttonNode.color = .blue
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if touchedNode.name == "buttonNode" {
            
            if touchedInsideButton {
            
                let transition = SKTransition.crossFade(withDuration: 1.0)
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                scene!.view!.presentScene(gameScene, transition: transition)
                
            }
            
        }
        
        touchedInsideButton = false
        let buttonNode = childNode(withName: "buttonNode") as! SKSpriteNode
        buttonNode.color = .red
   
    }
    
}
