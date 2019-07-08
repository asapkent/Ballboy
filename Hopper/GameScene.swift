//
//  GameScene.swift
//  Hopper
//
//  Created by Alex Jeffers on 7/7/19.
//  Copyright © 2019 asapinc. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var footballer: SKSpriteNode?
    var footballTimer: Timer?
    var whistleTimer: Timer?
    //var footballField: SKSpriteNode?
    var sky: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var userScoreLabel: SKLabelNode?
    var finalUsersScoreLabel : SKLabelNode?
    
    var score = 0
    
    let footballerCategory : UInt32 = 0x1 << 1
    let footballCategory : UInt32 = 0x1 << 2
    let whistleCategory : UInt32 = 0x1 << 3
    let footballFieldAndSkyCategory : UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        
        // Lets you know when you have hit/touched an object
        physicsWorld.contactDelegate = self
        
        // Get label node from scene and store it for use later
        footballer = childNode(withName: "Footballer") as? SKSpriteNode
        footballer?.physicsBody?.categoryBitMask = footballerCategory
        footballer?.physicsBody?.contactTestBitMask = footballCategory | whistleCategory
        footballer?.physicsBody?.collisionBitMask = footballFieldAndSkyCategory // contact made but does not move player
        
        var footballRun : [SKTexture] = []
        for number in 1...4 {
            footballRun.append(SKTexture(imageNamed: "ballboy-\(number)"))
        }
        
       footballer?.run(SKAction.repeatForever(SKAction.animate(with: footballRun, timePerFrame: 0.09)))
        
        
//        footballField = childNode(withName: "field") as? SKSpriteNode
//        footballField?.physicsBody?.categoryBitMask = footballFieldAndSkyCategory
//        footballField?.physicsBody?.collisionBitMask = footballerCategory
        
        sky = childNode(withName: "sky") as? SKSpriteNode
        sky?.physicsBody?.categoryBitMask = footballFieldAndSkyCategory
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        
        
        //createFootball()
        
       timers()
       grass()
    }

    func timers() {
        // footballs randomly generate on own time.
        footballTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.createFootball()
        })
        
        whistleTimer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
            self.createWhistles()
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
       
        // keeps clicks on playyer from happening when paused
        if scene?.isPaused == false {
        footballer?.physicsBody?.applyForce(CGVector(dx: 0, dy: 100_000))
        }
        
        
        let touch = touches.first
        if  let location = touch?.location(in: self) {
           let touchedNodes = nodes(at:location)
            
            for node in touchedNodes {
                if node.name == "play" {
                    // restart game
                    score = 0
                    node.removeFromParent()
                    finalUsersScoreLabel?.removeFromParent()
                    userScoreLabel?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Fumbles: \(score)"
                    timers()
                }
            }
     }
   }
    
    func createFootball() {
        let footballs = SKSpriteNode(imageNamed: "american-football")
        footballs.physicsBody = SKPhysicsBody(rectangleOf: footballs.size) // adding physic body for football.
        footballs.physicsBody?.affectedByGravity = false
        footballs.physicsBody?.categoryBitMask = footballCategory
        footballs.physicsBody?.contactTestBitMask = footballerCategory
        footballs.physicsBody?.collisionBitMask = 0
        
        let sizzingGrass = SKSpriteNode(imageNamed: "grass")
        
        
         let maxY = size.height / 2 - footballs.size.height / 2
         let minY = -size.height / 2 + footballs.size.height / 2 + sizzingGrass.size.height
         let range = maxY - minY
         let footballY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        let moveLeft = SKAction.moveBy(x: -size.width - footballs.size.width, y: 0, duration: 4)
        addChild(footballs)
        
        footballs.position = CGPoint(x: size.width / 2 + footballs.size.width, y: footballY
        )
        
        
        
        // moves footballs left then removes them from screen.
        footballs.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func createWhistles() {
        let whistle = SKSpriteNode(imageNamed: "whistle")
        whistle .physicsBody = SKPhysicsBody(rectangleOf: whistle.size) // adding physic body for whistle.
        whistle.physicsBody?.affectedByGravity = false
        whistle.physicsBody?.categoryBitMask = whistleCategory
        whistle.physicsBody?.contactTestBitMask = footballerCategory
        whistle.physicsBody?.collisionBitMask = 0
        addChild(whistle)
        
        let sizzingGrass = SKSpriteNode(imageNamed: "grass")
        
        let maxY = size.height / 2 - whistle.size.height / 2
        let minY = -size.height / 2 + whistle.size.height / 2 + sizzingGrass.size.height
        let range = maxY - minY
        let whistleY = maxY - CGFloat(arc4random_uniform(UInt32(range)))
        
        let moveLeft = SKAction.moveBy(x: -size.width - whistle.size.width, y: 0, duration: 4)
     
        
        whistle.position = CGPoint(x: size.width / 2 + whistle.size.width, y: whistleY
        )
        
        // moves whistles left then removes them from screen.
       whistle.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // this makes footballs disapear if contacted.
        if contact.bodyA.categoryBitMask == footballCategory {
            score += 1
            scoreLabel?.text = "score: \(score)"
            contact.bodyA.node?.removeFromParent()
        }
        if contact.bodyB.categoryBitMask == footballCategory {
            score += 1
            scoreLabel?.text = "score: \(score)"
            contact.bodyB.node?.removeFromParent()
        }
        
        // if contact with whistle
        if contact.bodyA.categoryBitMask == whistleCategory {
            contact.bodyA.node?.removeFromParent()
            endGame()
        }
        if contact.bodyB.categoryBitMask == whistleCategory {
            contact.bodyB.node?.removeFromParent()
            endGame()
        }
    }
    
    func endGame() {
        scene?.isPaused = true
        
        footballTimer?.invalidate()
        whistleTimer?.invalidate()
        
        userScoreLabel = SKLabelNode(text: "Fumbles Recovered:")
        userScoreLabel?.position = CGPoint(x: 0, y: 200)
        userScoreLabel?.fontSize = 70
        userScoreLabel?.zPosition = 1 // set in foreground
        if userScoreLabel != nil {
            addChild(userScoreLabel!)
        }
        
        finalUsersScoreLabel = SKLabelNode(text: "\(score)")
        finalUsersScoreLabel?.position = CGPoint(x: 0, y: 0)
        finalUsersScoreLabel?.fontSize = 200
        finalUsersScoreLabel?.zPosition = 1 // set in foreground
        if finalUsersScoreLabel != nil {
            addChild(finalUsersScoreLabel!)
        }
        
        let playAaginButton = SKSpriteNode(imageNamed: "play")
        playAaginButton.position = CGPoint(x: 0, y: -190)
        playAaginButton.name = "play"
        playAaginButton.zPosition = 1 // set in foreground
        addChild(playAaginButton)
    }
    
    func grass() {
        let grass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width / grass.size.width) + 1
        
        for number in  0...numberOfGrass {
            let sizzingGrass = SKSpriteNode(imageNamed: "grass")
            sizzingGrass.physicsBody = SKPhysicsBody(rectangleOf: sizzingGrass.size)
            sizzingGrass.physicsBody?.categoryBitMask = footballFieldAndSkyCategory
            sizzingGrass.physicsBody?.collisionBitMask = footballerCategory
            sizzingGrass.physicsBody?.affectedByGravity = false
            sizzingGrass.physicsBody?.isDynamic = false
            addChild(sizzingGrass)
            
          let grassX = -size.width / 2 + sizzingGrass.size.width / 2 + 35 + sizzingGrass.size.width * CGFloat(number)
              sizzingGrass.position = CGPoint(x: grassX, y: -size.height / 2 + sizzingGrass.size.height / 2 + 15)
            let speed : Double = 100.0
            let moveLeft = SKAction.moveBy(x: -sizzingGrass.size.width - sizzingGrass.size.width * CGFloat(number), y: 0, duration: TimeInterval(sizzingGrass.size.width + sizzingGrass.size.width * CGFloat(number)) / speed)
            
            let resetField = SKAction.moveBy(x: size.width + sizzingGrass.size.width, y: 0, duration: 0)
            let fieldMove = SKAction.moveBy(x: -size.width - sizzingGrass.size.width, y: 0, duration: TimeInterval(size.width + sizzingGrass.size.width) / speed)
            let fieldMoving = SKAction.repeatForever(SKAction.sequence([fieldMove, resetField ]))
            
            sizzingGrass.run(SKAction.sequence([moveLeft,resetField,fieldMoving]))
        }
    }
}
