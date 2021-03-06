//
//  GameScene.swift
//  Pong
//
//  Created by MPP on 22/5/18.
//  Copyright © 2018 Matthew Purcell. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let BallCategory: UInt32 = 0x1 << 0
    let BottomCategory: UInt32 = 0x1 << 1
    let BrickCategory: UInt32 = 0x1 << 2
    
    var bottomPaddle: SKSpriteNode?
    
    var bottomScore: SKLabelNode?
    
    var fingerOnBottomPaddle: Bool = false
    
    var ball: SKSpriteNode?
    
    var gameRunning: Bool = false
    
    var topScoreCount: Int = 0
    var bottomScoreCount: Int = 0
    
    var totalBricks: Int = 0
    
    var totalTime: Int = 0
    var gameTimer: Timer?
    
    override func didMove(to view: SKView) {
        
        bottomPaddle = self.childNode(withName: "bottomPaddle") as? SKSpriteNode
        bottomPaddle!.physicsBody = SKPhysicsBody(rectangleOf: bottomPaddle!.frame.size)
        bottomPaddle!.physicsBody!.isDynamic = false
        
        bottomScore = self.childNode(withName: "bottomScore") as? SKLabelNode
        
        ball = self.childNode(withName: "ball") as? SKSpriteNode
        ball!.physicsBody = SKPhysicsBody(rectangleOf: ball!.frame.size)
        ball!.physicsBody!.restitution = 1.0
        ball!.physicsBody!.friction = 0.0
        ball!.physicsBody!.linearDamping = 0.0
        ball!.physicsBody!.angularDamping = 0.0
        ball!.physicsBody!.allowsRotation = false
        ball!.physicsBody!.categoryBitMask = BallCategory
        ball!.physicsBody!.contactTestBitMask = BottomCategory | BrickCategory
        
        // Setup the emitter node
        let ballTrail = SKEmitterNode(fileNamed: "BallTrail")
        ball!.addChild(ballTrail!)
        ball!.zPosition = 1
        ballTrail!.targetNode = self
        
        // Configure the physics world
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        
        // Points
        let bottomLeftPoint = CGPoint(x: -(size.width / 2), y: -(size.height / 2))
        let bottomRightPoint = CGPoint(x: size.width / 2, y: -(size.height / 2))
        
        // Bottom node
        let bottomNode = SKNode()
        bottomNode.physicsBody = SKPhysicsBody(edgeFrom: bottomLeftPoint, to: bottomRightPoint)
        bottomNode.physicsBody!.categoryBitMask = BottomCategory
        addChild(bottomNode)
        
        // Generates the bricks
        generateBricks()
        
    }
    
    func generateBricks() {
        
        let numberOfBricks = 2
        let gapBetweenBricks = 10
        let numberOfRows = 1
        
        totalBricks = numberOfBricks * numberOfRows
        
        let anchorCompensation = (frame.size.width / 2)
        let totalGapBetweenBricks = gapBetweenBricks * (numberOfBricks - 1)
        let brickWidth = (frame.size.width - CGFloat(totalGapBetweenBricks)) / CGFloat(numberOfBricks)
        let brickWidthCompensation = brickWidth / 2
        
        var yCoord = (frame.size.height / 2) - 100
        
        let colorArray = [UIColor.red, UIColor.blue, UIColor.brown, UIColor.cyan, UIColor.green, UIColor.purple, UIColor.magenta, UIColor.yellow]
        
        for _ in 0..<numberOfRows {
            
            for i in 0..<numberOfBricks {
                
                let gapOffset = CGFloat(i * gapBetweenBricks)
                let xCoord = (CGFloat(i) * brickWidth) - anchorCompensation + brickWidthCompensation + gapOffset
                
                let randomColorIndex = Int(arc4random_uniform(8))
                
                let brickSpriteNode = SKSpriteNode(color: colorArray[randomColorIndex], size: CGSize(width: brickWidth, height: 25))
                brickSpriteNode.name = "brick"
                brickSpriteNode.position = CGPoint(x: CGFloat(xCoord), y: CGFloat(yCoord))
                brickSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: brickSpriteNode.size)
                brickSpriteNode.physicsBody!.isDynamic = false
                brickSpriteNode.physicsBody!.categoryBitMask = BrickCategory
                addChild(brickSpriteNode)
                
            }
            
            yCoord -= 50
            
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let touchedNode = atPoint(touchLocation)
        
        if touchedNode.name == "bottomPaddle" {
            fingerOnBottomPaddle = true
        }
        
        if gameRunning == false {
            
            let randomNumber = Int(arc4random_uniform(2))
            
            if randomNumber == 0 {
            
                ball!.physicsBody!.applyImpulse(CGVector(dx: 5, dy: 5))
                
            }
            
            else {
                
                ball!.physicsBody!.applyImpulse(CGVector(dx: -5, dy: -5))
                
            }
            
            gameRunning = true
            
            gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (theTimer) in
                self.totalTime += 1
                self.bottomScore!.text = String(self.totalTime)
            })

        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first!
        let touchLocation = touch.location(in: self)
        let previousTouchLocation = touch.previousLocation(in: self)
        
        if fingerOnBottomPaddle == true && touchLocation.y < 0 {
            let paddleX = bottomPaddle!.position.x + (touchLocation.x - previousTouchLocation.x)
            
            if ((paddleX - (bottomPaddle!.size.width / 2)) > -(self.size.width / 2)) && ((paddleX + (bottomPaddle!.size.width / 2)) < (self.size.width / 2)) {
                bottomPaddle!.position = CGPoint(x: paddleX, y: bottomPaddle!.position.y)
            }
            
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if fingerOnBottomPaddle == true {
            fingerOnBottomPaddle = false
        }
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func resetGame() {
        
        // Reset the ball position to the middle
        ball!.position.x = 0
        ball!.position.y = 0
        
        // Reset physics
        ball!.physicsBody!.isDynamic = false
        ball!.physicsBody!.isDynamic = true
        
        // Reset the paddle positions
        bottomPaddle!.position.x = 0
        
        // Reset gameRunning variable
        gameRunning = false
        
        // Reset the timer
        totalTime = 0
        bottomScore!.text = "0"
        gameTimer = nil
        
        // Regenerate bricks
        removeAllBricks()
        generateBricks()
        
        // Unpause the game
        view!.isPaused = false
        
    }
    
    func gameOver() {
        
        view!.isPaused = true
        gameTimer!.invalidate()
        
        let gameOverAlert = UIAlertController(title: "Game Over", message: nil, preferredStyle: .alert)
        
        let gameOverAction = UIAlertAction(title: "Okay", style: .default) { (theAlertAction) in
            
            self.resetGame()
            
        }
        
        gameOverAlert.addAction(gameOverAction)
        
        view!.window!.rootViewController!.present(gameOverAlert, animated: true, completion: nil)
        
    }
    
    func removeAllBricks() {
        
        scene!.enumerateChildNodes(withName: "brick") {
            (node, _) in
                node.removeFromParent()
        }
        
    }
    
    func checkForWin() {
        
        if totalBricks == 0 {
            
            view!.isPaused = true
            gameTimer!.invalidate()
            
            let winAlertController = UIAlertController(title: "You Won!", message: nil, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Okay", style: .default) { (alertAction) in
                self.resetGame()
            }
            winAlertController.addAction(dismissAction)
            view!.window!.rootViewController!.present(winAlertController, animated: true, completion: nil)
            
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
       if (contact.bodyA.categoryBitMask == BottomCategory) || (contact.bodyB.categoryBitMask == BottomCategory) {
            
            print("Bottom Contact")
            
            gameOver()
            
        }
        
        else if (contact.bodyA.categoryBitMask == BrickCategory) {
        
            let emitter = SKEmitterNode(fileNamed: "BrickExplode")
            emitter!.position = contact.bodyA.node!.position
            addChild(emitter!)
            contact.bodyA.node!.removeFromParent()
        
            let emitterDelay = SKAction.wait(forDuration: 2.0)
            let emitterOpacity = SKAction.fadeOut(withDuration: 1.0)
            let emitterRemove = SKAction.removeFromParent()
        
            emitter!.run(SKAction.sequence([emitterDelay, emitterOpacity, emitterRemove]))
        
            totalBricks -= 1
        
            let explosionAudioAction = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
            contact.bodyA.node!.run(explosionAudioAction)
        
            checkForWin()
            
        }
        
       else if (contact.bodyB.categoryBitMask == BrickCategory) {
        
            let emitter = SKEmitterNode(fileNamed: "BrickExplode")
            emitter!.position = contact.bodyB.node!.position
            addChild(emitter!)
            contact.bodyB.node!.removeFromParent()
        
            let emitterDelay = SKAction.wait(forDuration: 2.0)
            let emitterOpacity = SKAction.fadeOut(withDuration: 1.0)
            let emitterRemove = SKAction.removeFromParent()
        
            emitter!.run(SKAction.sequence([emitterDelay, emitterOpacity, emitterRemove]))
        
            totalBricks -= 1
        
            let explosionAudioAction = SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false)
            contact.bodyA.node!.run(explosionAudioAction)
        
            checkForWin()
        
        }
    
        
    }
    
}

















