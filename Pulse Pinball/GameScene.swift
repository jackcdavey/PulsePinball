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
    var isPullingBack = false

    var originalPinballPosition: CGPoint?
    var originalLauncherPosition: CGPoint?

    
    
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
        
        originalLauncherPosition = launcher?.position
        originalPinballPosition = pinball?.position
        
        
        
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
        
//        Reset button
        let resetButton = SKLabelNode(text: "Reset")
        resetButton.name = "resetButton"
        resetButton.position = CGPoint(x: 0, y: size.height / 2 - 50)
        addChild(resetButton)

        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Get the location of the touch
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        
        // Print the location of the touch
        print("Tapped at: \(location)")
        
        // Record the time the touch started
        touchStart = touch.timestamp
        
        

        // Check if the reset button was tapped
        if let node = nodes(at: location).first, node.name == "resetButton" {
            // Reset the pinball
            pinball?.position = originalPinballPosition!
            pinball?.physicsBody?.velocity = CGVector.zero
            return
        }
        
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
            isPullingBack = true
            launcher?.run(pullBack)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check if the launcher is being pulled back
        if isPullingBack {
            // Get the location of the touch
            guard let touch = touches.first else { return }
            var location = touch.location(in: self)

            // Constrain the location so the launcher doesn't move left/right or too high
            location.x = originalLauncherPosition?.x ?? location.x
            location.y = min(location.y, originalLauncherPosition?.y ?? location.y)
            location.y = max(location.y, (originalLauncherPosition?.y ?? location.y) - launcher!.size.height)

            // Move the launcher to the constrained location
            let pullBack = SKAction.move(to: location, duration: 0.1)
            launcher?.run(pullBack)
        }
    }


    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Stop pulling back the launcher
        isPullingBack = false

        // Get the location of the touch
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Calculate how far the launcher was pulled back
        let pullBackDistance = originalLauncherPosition!.y - launcher!.position.y

        // Use the pull back distance to determine the launch force
        let launchForce = pullBackDistance * 50.0

        // Define actions for the launcher
        let moveLauncherBack = SKAction.move(to: originalLauncherPosition!, duration: 0.1)
        let launchBall = SKAction.run {
            let launch = SKAction.applyImpulse(CGVector(dx: 0, dy: launchForce), duration: 0.1)
            self.pinball?.run(launch)
        }
        
        // If the middle third of the screen was initially touched, move the launcher back and launch the ball
        if location.x > -size.width / 6 && !(location.x > 0 && location.x < size.width / 6) {
            let launchSequence = SKAction.sequence([moveLauncherBack, launchBall])
            launcher?.run(launchSequence)
        }
    }




    
    
}








