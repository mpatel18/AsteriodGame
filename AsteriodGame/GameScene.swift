//
//  GameScene.swift
//  AsteriodGame
//
//  Created by meekit on 4/28/19.
//  Copyright © 2019 meekit. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    /*private var lastUpdateTime : TimeInterval = 0
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
    }*/
    
    var background: SKEmitterNode!
    var ship: SKSpriteNode!
    let rocks = ["rock1", "rock2"]
    let powerUps = ["speedUp", "slowDown", "addScore", "addLife", "dead", "doubleScore", "clearScreen"]
    var animationTime: TimeInterval = 9
    
    var timeInterval: TimeInterval = 0.9
    var timer: Timer!
    
    let motionManager = CMMotionManager()
    var xMove = CGFloat(0)
    var lives: Int = 3
    var livesNode: [SKSpriteNode] = []
    var score: Int = 0
    var scoreMultiplyer = 1
    
    override func didMove(to view: SKView) {
        updateLives(diff: 0)
        
        background = SKEmitterNode(fileNamed: "Background")
        background.position = CGPoint(x: 0, y: self.view!.bounds.height)
        background.advanceSimulationTime(20)
        self.addChild(background)
        
        background.zPosition = -2
        
        ship = SKSpriteNode(imageNamed: "ship")
        ship.name = "ship"
        ship.position = CGPoint(x: 0, y: self.frame.size.height / -2.2)
        ship.physicsBody = SKPhysicsBody(circleOfRadius: ship.size.width / 2)
        ship.physicsBody?.isDynamic = true
        ship.physicsBody?.collisionBitMask = 0
        ship.physicsBody?.contactTestBitMask = 1
        ship.physicsBody?.categoryBitMask = 3
        ship.physicsBody?.usesPreciseCollisionDetection = true
        self.addChild(ship)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rockDown), userInfo: nil, repeats: true)

        
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) {(data: CMAccelerometerData?, error: Error?) in
            if let moveData = data {
                let move = moveData.acceleration
                self.xMove = CGFloat(move.x) * 0.75 + self.xMove * 0.25
            }
        }
    }
    
    @objc func rockDown() {
        let name = rocks[Int.random(in: 0..<2)]
        let rock = SKSpriteNode(imageNamed: name)
        rock.name = name
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
        rock.physicsBody?.collisionBitMask = 2
        rock.physicsBody?.contactTestBitMask = 1
        rock.physicsBody?.categoryBitMask = 1
        rock.physicsBody?.usesPreciseCollisionDetection = true
        //print("\(px) \(rock) \(self.frame.size.height)")
        self.addChild(rock)
        
        rock.run(SKAction.move(to: CGPoint(x: px, y: -py), duration: animationTime))
        
        rock.run(SKAction.wait(forDuration: animationTime)) {
            rock.removeFromParent()
        }
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fire()
    }
    
    func fire() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "bullet"
        self.run(SKAction.playSoundFileNamed("Gun.mp3", waitForCompletion: false))
        bullet.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.size.height / 2)
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: bullet.size.width / 2)
        bullet.physicsBody?.isDynamic = true
        bullet.physicsBody?.collisionBitMask = 1
        bullet.physicsBody?.contactTestBitMask = 1
        bullet.physicsBody?.categoryBitMask = 0
        bullet.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(bullet)
        
        bullet.run(SKAction.move(to: CGPoint(x: bullet.position.x, y: self.frame.size.height / 2 + bullet.size.height), duration: animationTime / 20))
        
        bullet.run(SKAction.wait(forDuration: animationTime / 20)) {
            bullet.removeFromParent()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //bodyA will either be rock or ship
        var bodyA: SKPhysicsBody = contact.bodyA
        var bodyB: SKPhysicsBody = contact.bodyB
        
        //if the bodyA is rock, then we need to handle the cases where bodyB is bullet or ship
        if (contact.bodyA.node?.name == "rock1" || contact.bodyA.node?.name == "rock2") {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
            //print(bodyB.node?.name)
        //if the bodyB is rock, then we need to handle the cases where bodyB is bullet or ship
        } else if (contact.bodyB.node?.name == "rock1" || contact.bodyB.node?.name == "rock2") {
            bodyB = contact.bodyA
            bodyA = contact.bodyB
            //print(bodyB.node?.name)
        //if the bodyA is ship and bodyB is not rock, then we need to handle the cases where bodyB is powerup
        } else if (contact.bodyA.node?.name == "ship") {
            //print("1111")
            bodyA = contact.bodyA
            bodyB = contact.bodyB
        } else if (contact.bodyB.node?.name == "ship") {
            //print("2222")
            bodyB = contact.bodyA
            bodyA = contact.bodyB
        }
        /*if ((contact.bodyA.categoryBitMask == 1 && contact.bodyB.categoryBitMask == 2) || (contact.bodyA.categoryBitMask == 2 && contact.bodyB.categoryBitMask == 1)) {
            distoryRock(bodyA: contact.bodyA, bodyB: contact.bodyB)
        }*/
        
        //When a rock hitted by a bullet or ship
        if (bodyA.node?.name == "rock1" || bodyA.node?.name == "rock2") {
            //print("bodyA: \(bodyA.node?.name)")
            if (bodyB.node?.name == "bullet" || bodyB.node?.name == "deadline") {
                distoryRock(rock: bodyA, bullet: bodyB)
                //print("bodyB: \(bodyB.node?.name)")
            } else if (bodyB.node?.name == "ship") {
                distoryShip(rock: bodyA, ship: bodyB)
            }
        //when a ship picked a powerup
        } else if (bodyA.node?.name == "ship") {
            //print("ship")
            if (powerUps.contains((bodyB.node?.name)!)) {
                //print("run")
                bodyB.node?.removeFromParent()
                if (bodyB.node?.name == "speedUp") {
                    speedUp()
                } else if (bodyB.node?.name == "slowDown") {
                    slowDown()
                } else if (bodyB.node?.name == "addScore") {
                    addScore()
                } else if (bodyB.node?.name == "addLife") {
                    addLife()
                } else if (bodyB.node?.name == "dead") {
                    dead()
                } else if (bodyB.node?.name == "doubleScore") {
                    doubleScore()
                } else if (bodyB.node?.name == "clearScreen") {
                    clearScreen()
                }
            }
        }
    }
    
    func speedUp() {
        print(timeInterval)
        if (self.animationTime > 3) {
            self.animationTime -= 3
            self.timeInterval -= 0.3
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rockDown), userInfo: nil, repeats: true)
        }
    }
    
    func slowDown() {
        print(timeInterval)
        if (self.animationTime < 15) {
            self.animationTime += 3
            self.timeInterval += 0.3
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rockDown), userInfo: nil, repeats: true)
        }
    }
    
    func addScore() {
        self.score += 100
    }
    
    func addLife() {
        self.lives += 1
        updateLives(diff: 1)
    }
    
    func dead() {
        while self.lives > 0 {
            self.lives -= 1
            updateLives(diff: -1)
        }
        gameOver()
    }
    
    func doubleScore() {
        if (scoreMultiplyer < 8) {
            scoreMultiplyer *= 2
        }
    }
    
    func clearScreen() {
        let deadline = SKSpriteNode(imageNamed: "deadline")
        deadline.name = "deadline"
        self.run(SKAction.playSoundFileNamed("Gun.mp3", waitForCompletion: false))
        deadline.position = CGPoint(x: ship.position.x, y: ship.position.y + ship.size.height / 2)
        deadline.physicsBody = SKPhysicsBody(rectangleOf: deadline.size)
        deadline.physicsBody?.isDynamic = true
        deadline.physicsBody?.collisionBitMask = 1
        deadline.physicsBody?.contactTestBitMask = 1
        deadline.physicsBody?.categoryBitMask = 0
        deadline.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(deadline)
        
        deadline.run(SKAction.move(to: CGPoint(x: deadline.position.x, y: self.frame.size.height / 2), duration: animationTime / 2))
        
        deadline.run(SKAction.wait(forDuration: animationTime / 2)) {
            deadline.removeFromParent()
        }
    }
    
    func distoryRock(rock: SKPhysicsBody, bullet: SKPhysicsBody) {
        let myParticle = SKEmitterNode(fileNamed: "MyParticle.sks")!
        myParticle.position = (rock.node?.position)!
        self.addChild(myParticle)
        rock.node?.removeFromParent()
        if (bullet.node?.name == "bullet") {
            bullet.node?.removeFromParent()
        }
        score += 1 * scoreMultiplyer
        let powerUpChance = Int.random(in: 6..<10)
        if (powerUpChance < powerUps.count) {
            let powerUpName = powerUps[powerUpChance]
            let powerUp = SKSpriteNode(imageNamed: powerUpName)
            powerUp.name = powerUpName
            powerUp.position = (rock.node?.position)!
            powerUp.physicsBody = SKPhysicsBody(circleOfRadius: powerUp.size.width / 2)
            powerUp.physicsBody?.isDynamic = true
            powerUp.physicsBody?.collisionBitMask = 6
            powerUp.physicsBody?.contactTestBitMask = 1
            powerUp.physicsBody?.categoryBitMask = 0
            powerUp.physicsBody?.usesPreciseCollisionDetection = true
            self.addChild(powerUp)
            let halfHeight = self.frame.size.height / 2
            let endPoint = -halfHeight - powerUp.size.height
            let boundary = Int(self.frame.size.width / 2 - powerUp.size.width)
            /*while powerUp.position.y > endPoint {
                powerUp.run(SKAction.move(to: CGPoint(x: powerUp.position.x + CGFloat(Int.random(in: -10...10)), y: powerUp.position.y + 10), duration: animationSpeed / Double(endPoint)))
            }*/
            let duration = animationTime * Double((powerUp.position.y + halfHeight) / halfHeight) / 4
            //powerUp.run(SKAction.move(to: CGPoint(x: CGFloat(Int.random(in: -boundary...boundary)), y: endPoint), duration: duration))
            powerUp.run(SKAction.move(to: ship.position, duration: duration))
            powerUp.run(SKAction.wait(forDuration: duration)) {
                powerUp.removeFromParent()
            }
        }
        var actions = [SKAction]()
        actions.append(SKAction.playSoundFileNamed("Bomb.mp3", waitForCompletion: false))
        actions.append(SKAction.wait(forDuration: 2))
        actions.append(SKAction.removeFromParent())
        self.run(SKAction.sequence(actions))
    }
    
    func distoryShip(rock: SKPhysicsBody, ship: SKPhysicsBody) {
        let myParticle = SKEmitterNode(fileNamed: "MyParticle.sks")!
        myParticle.position = (ship.node?.position)!
        self.addChild(myParticle)
        rock.node?.removeFromParent()
        //ship.node?.removeFromParent()
        
        var actions = [SKAction]()
        actions.append(SKAction.playSoundFileNamed("Bomb.mp3", waitForCompletion: false))
        actions.append(SKAction.wait(forDuration: 2))
        actions.append(SKAction.removeFromParent())
        self.run(SKAction.sequence(actions))
        
        lives -= 1
        if lives >= 0 {
            updateLives(diff: -1)
        }
        if lives == 0{
            gameOver()
        }
    }
    
    func gameOver() {
        return
    }
    
    override func didSimulatePhysics() {
        let xLimit = (self.frame.size.width - ship.size.width) / 2
        ship.position.x += xMove * 50
        
        if ship.position.x < -xLimit {
            ship.position.x = -xLimit
        } else if ship.position.x > xLimit {
            ship.position.x = xLimit
        }
    }
    
    //to update the remaning lives
    func updateLives(diff: Int) {
        //print(lives)
        //Initialize the lives
        if (diff == 0) {
            for i in 1...lives {
                let oneLive = SKSpriteNode(imageNamed: "ship")
                oneLive.size.width *= 0.6
                oneLive.size.height *= 0.6
                oneLive.position = CGPoint(x: self.frame.size.width / 2 - CGFloat(i + 1) * oneLive.size.width * 1.1, y: self.frame.size.height / 2 - oneLive.size.height * 1.5)
                self.addChild(oneLive)
                livesNode.append(oneLive)
            }
        //When a rock hit the ship, the lives decrease
        } else if (diff == -1) {
            let oneLive = livesNode.last
            oneLive?.removeFromParent()
            livesNode.removeLast()
        //when get a +1 life powerup, the lives increase
        } else if (diff == 1) {
            let oneLive = SKSpriteNode(imageNamed: "ship")
            oneLive.size.width *= 0.6
            oneLive.size.height *= 0.6
            oneLive.position = CGPoint(x: self.frame.size.width / 2 - CGFloat(lives + 1) * oneLive.size.width * 1.1, y: self.frame.size.height / 2 - oneLive.size.height * 1.5)
            self.addChild(oneLive)
            livesNode.append(oneLive)
        }
    }
}
