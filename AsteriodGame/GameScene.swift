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
    
    var backgrounds = ["Background0", "Background1", "Background2"]
    var background: SKEmitterNode!
    var ship: SKSpriteNode!
    let rocks = ["rock1", "rock2", "rock3"]
    let powerUps = ["slowDown", "addScore", "addLife", "doubleScore", "clearScreen", "tripleBullet", "dead", "speedUp", "singleBullet"]
    var animationTime: TimeInterval = 9
    
    var timeInterval: TimeInterval = 0.9
    var timer: Timer!
    
    let motionManager = CMMotionManager()
    var xMove = CGFloat(0)
    var lives: Int = 3
    var livesNode: [SKSpriteNode] = []
    var score: Int = 0
    var scoreMultiplyer = 1
    var tripleBullet = 1
    
    override func didMove(to view: SKView) {
        updateLives(diff: 0)
        
        for i in 0..<backgrounds.count {
            setBackground(val: i)
        }
        
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
    
    func setBackground(val: Int) {
        background = SKEmitterNode(fileNamed: backgrounds[val])
        background.position = CGPoint(x: 0, y: self.view!.bounds.height)
        background.advanceSimulationTime(TimeInterval(5 * val + 10))
        background.zPosition = CGFloat(val - 5)
        self.addChild(background)
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
        for i in 1..<tripleBullet {
            fire(direction: CGFloat(-i))
            fire(direction: CGFloat(i))
        }
        fire(direction: 0)
    }
    
    func fire(direction: CGFloat) {
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
        
        bullet.run(SKAction.move(to: CGPoint(x: bullet.position.x + direction * self.frame.size.width, y: self.frame.size.height / 2 + bullet.size.height), duration: animationTime / 20))
        
        bullet.run(SKAction.wait(forDuration: animationTime / 20)) {
            bullet.removeFromParent()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        //bodyA will either be rock or ship
        var bodyA: SKPhysicsBody = contact.bodyA
        var bodyB: SKPhysicsBody = contact.bodyB
        
        //if the bodyA is rock, then we need to handle the cases where bodyB is bullet or ship
        if (contact.bodyA.collisionBitMask == 2) {
            bodyA = contact.bodyA
            bodyB = contact.bodyB
            //print(bodyB.node?.name)
        //if the bodyB is rock, then we need to handle the cases where bodyB is bullet or ship
        } else if (contact.bodyB.collisionBitMask == 2) {
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
        if (bodyA.collisionBitMask == 2) {
            //print("bodyA: \(bodyA.node?.name)")
            if (bodyB.node?.name == "bullet" || bodyB.node?.name == "deadline") {
                distoryRock(rock: bodyA, bullet: bodyB)
                //print("bodyB: \(bodyB.node?.name)")
            } else if (bodyB.node?.name == "ship") {
                distoryShip(rock: bodyA, ship: bodyB)
            }
        //when a ship picked a powerup, it will generate a powerUp node and play relative sound effect.
        } else if (bodyA.node?.name == "ship") {
            //print("ship")
            if (powerUps.contains((bodyB.node?.name)!)) {
                //print("run")
                bodyB.node?.removeFromParent()
                if (bodyB.node?.name == "speedUp") {
                    self.run(SKAction.playSoundFileNamed("debuff.mp3", waitForCompletion: false))
                    speedUp()
                } else if (bodyB.node?.name == "slowDown") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    slowDown()
                } else if (bodyB.node?.name == "addScore") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    addScore()
                } else if (bodyB.node?.name == "addLife") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    addLife()
                } else if (bodyB.node?.name == "dead") {
                    self.run(SKAction.playSoundFileNamed("debuff.mp3", waitForCompletion: false))
                    dead()
                } else if (bodyB.node?.name == "doubleScore") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    doubleScore()
                } else if (bodyB.node?.name == "clearScreen") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    clearScreen()
                } else if (bodyB.node?.name == "tripleBullet") {
                    self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
                    tripleBullet += 1
                } else if (bodyB.node?.name == "singleBullet") {
                    self.run(SKAction.playSoundFileNamed("debuff.mp3", waitForCompletion: false))
                    tripleBullet = 1
                }
            }
        }
    }
    
    func speedUp() {
        //print(timeInterval)
        if (self.animationTime > 3) {
            self.animationTime -= 3
            self.timeInterval -= 0.3
            timer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(rockDown), userInfo: nil, repeats: true)
        }
    }
    
    func slowDown() {
        //print(timeInterval)
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
        //if the rock is a big rock, it will be shrinked to a smaller one.
        if (bullet.node?.name != "deadline" && rock.node?.name == "rock1") {
            let name = "rock3"
            let rock3 = SKSpriteNode(imageNamed: name)
            rock3.name = name
            let rockWidth = rock3.size.width
            let rockHeight = rock3.size.height
            //print(rockXRange)
            rock3.position = (rock.node?.position)!
            rock3.zRotation = CGFloat(Int.random(in: 0..<360))
            rock3.physicsBody = SKPhysicsBody(circleOfRadius: rockWidth / 2)
            rock3.physicsBody?.isDynamic = true
            rock3.physicsBody?.collisionBitMask = 2
            rock3.physicsBody?.contactTestBitMask = 1
            rock3.physicsBody?.categoryBitMask = 1
            rock3.physicsBody?.usesPreciseCollisionDetection = true
            //print("\(px) \(rock) \(self.frame.size.height)")
            self.addChild(rock3)
            let timeLeft = animationTime * Double(((rock.node?.position.y)! + self.frame.size.height / 2) / self.frame.size.height)
            rock3.run(SKAction.move(to: CGPoint(x: rock3.position.x, y: -self.frame.size.height / 2 - rockHeight), duration: timeLeft))
            
            rock3.run(SKAction.wait(forDuration: timeLeft)) {
                rock3.removeFromParent()
            }
        }
        rock.node?.removeFromParent()
        if (bullet.node?.name == "bullet") {
            bullet.node?.removeFromParent()
        }
        score += 1 * scoreMultiplyer
        let powerUpChance = Int.random(in: 0..<10)
        if (powerUpChance < powerUps.count) {
            if (powerUpChance < 6) {
                self.run(SKAction.playSoundFileNamed("buff.mp3", waitForCompletion: false))
            } else {
                self.run(SKAction.playSoundFileNamed("debuff.mp3", waitForCompletion: false))
            }
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
            powerUp.run(SKAction.move(to: CGPoint(x: CGFloat(Int.random(in: -boundary...boundary)), y: endPoint), duration: duration))
            //powerUp.run(SKAction.move(to: ship.position, duration: duration))
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
