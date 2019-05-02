//
//  GameScene.swift
//  AsteriodGame
//
//  Created by meekit on 4/28/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func sceneDidLoad() {

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.label = self.childNode(withName: "//helloLabel") as? SKLabelNode
        if let label = self.label {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    /*override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }*/
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
    
    var background: SKEmitterNode!
    var ship: SKSpriteNode!
    let rocks = ["rock1", "rock2"]
    var animationSpeed: TimeInterval = 8
    
    var timeInterval: TimeInterval = 1
    var timer: Timer!
    
    
    
    override func didMove(to view: SKView) {
        background = SKEmitterNode(fileNamed: "Background")
        background.position = CGPoint(x: 0, y: self.view!.bounds.height)
        background.advanceSimulationTime(20)
        self.addChild(background)
        
        background.zPosition = -2
        
        ship = SKSpriteNode(imageNamed: "ship")
        ship.position = CGPoint(x: 0, y: self.frame.size.height / -2.2)
        self.addChild(ship)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rockDown), userInfo: nil, repeats: true)
    }
    
    @objc func rockDown() {
        let rock = SKSpriteNode(imageNamed: rocks[Int.random(in: 0..<2)])
        let rockWidth = rock.size.width
        let rockHeight = rock.size.height
        let rockXRange = Int(self.frame.size.width - rockWidth * 2) / 2
        let py = self.frame.size.height / 2 + rockHeight
        let px = CGFloat(Int.random(in: (-rockXRange)...(rockXRange)))
        //print(rockXRange)
        rock.position = CGPoint(x: px, y: py)
        rock.zRotation = CGFloat(Int.random(in: 0..<360))
        rock.physicsBody = SKPhysicsBody(circleOfRadius: rockWidth / 2)
        rock.physicsBody?.isDynamic = true
        rock.physicsBody?.collisionBitMask = 0
        rock.physicsBody?.contactTestBitMask = 1
        rock.physicsBody?.categoryBitMask = 2
        //print("\(px) \(rock) \(self.frame.size.height)")
        self.addChild(rock)
        
        rock.run(SKAction.move(to: CGPoint(x: px, y: -py), duration: animationSpeed))
        
        rock.run(SKAction.wait(forDuration: animationSpeed)) {
            rock.removeFromParent()
        }
        
        /*var actions = [SKAction]()
        
        actions.append(SKAction.move(to: CGPoint(x: px, y: -py), duration: animationSpeed))
        actions.append(SKAction.removeFromParent())
        
        rock.run(SKAction.sequence(actions))
        //rock.run(removeRock)*/
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire()
    }
    
    func fire() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        self.run(SKAction.playSoundFileNamed("Gun.mp3", waitForCompletion: false))
        bullet.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.size.height / 2)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.collisionBitMask = 0
        bullet.physicsBody?.contactTestBitMask = 2
        bullet.physicsBody?.categoryBitMask = 1
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        bullet.run(SKAction.move(to: CGPoint(x: bullet.position.x, y: self.frame.size.height / 2 + bullet.size.height), duration: animationSpeed / 20))
        
        bullet.run(SKAction.wait(forDuration: animationSpeed / 20)) {
            bullet.removeFromParent()
        }
        
        /*var actions = [SKAction]()
        
        actions.append(SKAction.move(to: CGPoint(x: bullet.position.x, y: self.frame.size.height / 2 + bullet.size.height), duration: animationSpeed / 20))
        actions.append(SKAction.removeFromParent())
        
        bullet.run(SKAction.sequence(actions))*/
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        if ((contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2) || (contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1)) {
            distoryRock(bodyA: contact.bodyA, bodyB: contact.bodyB)
        }
    }
    
    func distoryRock(bodyA: SKPhysicsBody, bodyB: SKPhysicsBody) {
        let myParticle = SKEmitterNode(fileNamed: "MyParticle.sks")!
        if (bodyA.categoryBitMask == 2) {
            myParticle.position = (bodyA.node?.position)!
        } else {
            myParticle.position = (bodyB.node?.position)!
        }
        
        self.addChild(myParticle)
        var actions = [SKAction]()
        
        bodyA.node?.removeFromParent()
        bodyB.node?.removeFromParent()
        
        actions.append(SKAction.playSoundFileNamed("Bomb.mp3", waitForCompletion: false))
        actions.append(SKAction.wait(forDuration: 2))
        actions.append(SKAction.removeFromParent())
        self.run(SKAction.sequence(actions))
    }
}
