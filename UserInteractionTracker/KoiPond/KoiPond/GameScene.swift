//
//  GameScene.swift
//  KoiPond
//
//  Created by Isabel  Lee on 10/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//  Attribution: https://dezwitter.wordpress.com/2015/02/05/spritekit-with-swift-orienting-sprites-to-a-location/

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var koi1: SKSpriteNode?
    var koi2: SKSpriteNode?
    var koi3: SKSpriteNode?
    var koi4: SKSpriteNode?
    var koi5: SKSpriteNode?
    
    override func didMove(to view: SKView) {
        
        koi1 = SKSpriteNode(imageNamed: "koi_1")
        koi1!.xScale = 0.2
        koi1!.yScale = 0.2
        koi1!.position = CGPoint(x: frame.width / 2, y: frame.height / 2)
        self.addChild(koi1!)
    
        koi2 = SKSpriteNode(imageNamed: "koi_2")
        koi2!.xScale = 0.2
        koi2!.yScale = 0.2
        koi2!.position = CGPoint(x: 650, y: 650)
        self.addChild(koi2!)
        
        koi3 = SKSpriteNode(imageNamed: "koi_3")
        koi3!.xScale = 0.2
        koi3!.yScale = 0.2
        koi3!.position = CGPoint(x: 400, y: 400)
        self.addChild(koi3!)
        
        koi4 = SKSpriteNode(imageNamed: "koi_4")
        koi4!.xScale = 0.2
        koi4!.yScale = 0.2
        koi4!.position = CGPoint(x: 500, y: 500)
        self.addChild(koi4!)
        
        koi5 = SKSpriteNode(imageNamed: "koi_5")
        koi5!.xScale = 0.2
        koi5!.yScale = 0.2
        koi5!.position = CGPoint(x: 600, y: 600)
        self.addChild(koi5!)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        /* Called when a touch begins */
        // Capture the touch event.
        for touch in touches {
            // Get the position that was touched (a.k.a. ending point).
            let touchPosition = touch.location(in: self)
            
            let touchX = touchPosition.x
            let touchY = touchPosition.y
            
            //print("Touch location: \(touchX), \(touchY)")
            ActionTracker.tracker.recordTouch(x: touchX, y: touchY)
            
            // Get sprite's current position (a.k.a. starting point).
            let currentPosition = koi1!.position
            
            // Calculate the angle using the relative positions of the sprite and touch.
            let angle = atan2(currentPosition.y - touchPosition.y, currentPosition.x - touchPosition.x)
            
            // Define actions
            let rotateAction = SKAction.rotate(toAngle: angle + CGFloat(Double.pi*0.5), duration: 0)
            let moveAction = SKAction.move(to: touchPosition, duration: 2)
            let moveAction2 = SKAction.move(to: CGPoint(x: touchX + 50, y: touchY + 50), duration: 5)
            let moveAction3 = SKAction.move(to: CGPoint(x: touchX + 70, y: touchY + -70), duration: 10)
            let moveAction4 = SKAction.move(to: CGPoint(x: touchX + 90, y: touchY ), duration: 3)
            let moveAction5 = SKAction.move(to: CGPoint(x: touchX - 90, y: touchY + 30), duration: 6)
            
            // Execute actions.
            koi1!.run(SKAction.sequence([rotateAction, moveAction]))
            koi2!.run(SKAction.sequence([rotateAction, moveAction2]))
            koi3!.run(SKAction.sequence([rotateAction, moveAction3]))
            koi4!.run(SKAction.sequence([rotateAction, moveAction4]))
            koi5!.run(SKAction.sequence([rotateAction, moveAction5]))
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
