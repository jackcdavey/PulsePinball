//
//  GameScene.swift
//  Pulse Pinball
//
//  Created by Jack Davey on 7/22/23.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    // Declare the pinball, flippers, and launcher
    var pinball: SKSpriteNode?
    var leftFlipper: SKSpriteNode?
    var rightFlipper: SKSpriteNode?
    var launcher: SKSpriteNode?
    var leftWall: SKSpriteNode?
    var rightWall: SKSpriteNode?
    var outerWall: SKSpriteNode?
    var curveWall: SKSpriteNode?
    var touchStart: TimeInterval?

    
    
    
    override func didMove(to view: SKView) {
        
        // Set up the physics world
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -9.8)
        
        // Initialize the pinball, flippers, and launcher
        pinball = self.childNode(withName: "pinball") as? SKSpriteNode
        leftFlipper = self.childNode(withName: "leftFlipper") as? SKSpriteNode
        rightFlipper = self.childNode(withName: "rightFlipper") as? SKSpriteNode
        launcher = self.childNode(withName: "launcher") as? SKSpriteNode
        leftWall = self.childNode(withName: "leftWall") as? SKSpriteNode
        rightWall = self.childNode(withName: "rightWall") as? SKSpriteNode
        outerWall = self.childNode(withName: "outerWall") as? SKSpriteNode
        curveWall = self.childNode(withName: "curveWall") as? SKSpriteNode
        
        
        
        // Set up the pinball physics
        pinball?.physicsBody = SKPhysicsBody(circleOfRadius: pinball!.size.width/2)
        pinball?.physicsBody?.restitution = 0.5
        pinball?.physicsBody?.mass = 1.0
        
        
        // Set up the flipper physics
        leftFlipper?.physicsBody = SKPhysicsBody(rectangleOf: leftFlipper!.size)
        rightFlipper?.physicsBody = SKPhysicsBody(rectangleOf: rightFlipper!.size)
        
        // The flippers should not be affected by gravity or forces
        leftFlipper?.physicsBody?.isDynamic = false
        rightFlipper?.physicsBody?.isDynamic = false
        
        // The launcher should also not be affected by gravity or forces
        launcher?.physicsBody = SKPhysicsBody(rectangleOf: launcher!.size)
        launcher?.physicsBody?.isDynamic = false
        
        //Wall physics
        leftWall?.physicsBody = SKPhysicsBody(rectangleOf: leftWall!.size)
        rightWall?.physicsBody = SKPhysicsBody(rectangleOf: rightWall!.size)
        outerWall?.physicsBody = SKPhysicsBody(rectangleOf: outerWall!.size)
        curveWall?.physicsBody = SKPhysicsBody(rectangleOf: curveWall!.size)
        
        leftWall?.physicsBody?.isDynamic = false
        rightWall?.physicsBody?.isDynamic = false
        outerWall?.physicsBody?.isDynamic = false
        curveWall?.physicsBody?.isDynamic = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        
        // Print the location of the touch
        print("Tapped at: \(location)")
        
        // Record the time the touch started
        touchStart = touch.timestamp
        
        // Define actions for the flippers and the launcher
        let moveLeftUp = SKAction.rotate(byAngle: .pi / 4, duration: 0.1)
        let moveLeftDown = SKAction.rotate(byAngle: -.pi / 4, duration: 0.1)
        let moveRightUp = SKAction.rotate(byAngle: -.pi / 4, duration: 0.1)
        let moveRightDown = SKAction.rotate(byAngle: .pi / 4, duration: 0.1)
        let leftFlip = SKAction.sequence([moveLeftUp, moveLeftDown])
        let rightFlip = SKAction.sequence([moveRightUp, moveRightDown])
        let moveLauncherDown = SKAction.moveBy(x: 0, y: -100, duration: 0.5)
        let moveLauncherUp = SKAction.moveBy(x: 0, y: 110, duration: 0.05)
        
        // Apply an impulse to the ball when the launcher moves up
//        let launchBall = SKAction.run {
//            let launch = SKAction.applyImpulse(CGVector(dx: 0, dy: 3000), duration: 0.1)
//            self.pinball?.run(launch)
//        }
//        let launchSequence = SKAction.sequence([moveLauncherDown, moveLauncherUp, launchBall])
        
        let pullBack = SKAction.moveBy(x: 0, y: -10, duration: 0.1)

        
        
        // Check where the screen was touched
        if location.x < -size.width / 6 {
            // Left third of the screen: flip the left flipper
            leftFlipper?.run(leftFlip)
        } else if (location.x > 0 && location.x < size.width / 6) {
            // Right third of the screen: flip the right flipper
            rightFlipper?.run(rightFlip)
        } else {
            // Middle third of the screen: launch the ball
            launcher?.run(pullBack)
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Calculate the duration of the touch
        let touchDuration = touch.timestamp - (touchStart ?? touch.timestamp)

        // Use the touch duration to determine the launch force
        let launchForce = CGFloat(touchDuration) * 1000.0

        // Define launch action for the launcher
        let moveLauncherUp = SKAction.moveBy(x: 0, y: 10, duration: 0.1)
        let launchBall = SKAction.run {
            let launch = SKAction.applyImpulse(CGVector(dx: 0, dy: launchForce), duration: 0.1)
            self.pinball?.run(launch)
        }
        let launchSequence = SKAction.sequence([moveLauncherUp, launchBall])

        // If the middle third of the screen was initially touched, launch the ball
        if location.x > -size.width / 6 && !(location.x > 0 && location.x < size.width / 6) {
            launcher?.run(launchSequence)
        }
    }


    
    
}








