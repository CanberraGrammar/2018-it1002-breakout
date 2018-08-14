//
//  SplashScene.swift
//  Breakout
//
//  Created by MPP on 15/8/18.
//  Copyright © 2018 Matthew Purcell. All rights reserved.
//

import SpriteKit

class SplashScene: SKScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let transition = SKTransition.crossFade(withDuration: 1.0)
        let gameScene = SKScene(fileNamed: "GameScene")!
        gameScene.scaleMode = .aspectFill
        scene!.view!.presentScene(gameScene, transition: transition)
        
    }
    
}
