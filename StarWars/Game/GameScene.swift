/******************************************************************
*                                                                 *
*    GameScene.swift                                              *
*    StarWars                                                     *
*                                                                 *
*    Created by lagha on 03/03/2018.                              *
*    Copyright © 2018 lagha. All rights reserved.                 *
*                                                                 *
*******************************************************************/

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var sizeMinAlien: CGFloat = CGFloat(60)
    var scorInit: Bool = true
    var lifeInit:Bool = true
    var lifeLabel: SKLabelNode!
    var life = 100{
        didSet{
            lifeLabel.text = "Life: \(life)/100"
        }
    }
    var scoreLabel: SKLabelNode!
    var score: Int = 0{
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    let alienCategory: UInt32 = 0x1 << 1
    let torpedoCategory: UInt32 = 0x1 << 2
    let soldierCategory: UInt32 = 0x1 << 3
    var gameTimer: Timer!
    
    var menuButton: SKSpriteNode!
    
    
    override func sceneDidLoad() {
      
        scoreLabel = SKLabelNode()
        scoreLabel.position = CGPoint(x: -420, y: 345)
        scoreLabel.zPosition = 1
        scoreLabel.fontName = "AmericanTypewriter-Bold"
        scoreLabel.fontColor = SKColor.white
        
        lifeLabel = SKLabelNode()
        lifeLabel.position = CGPoint(x: 80, y: 345)
        lifeLabel.zPosition = 1
        lifeLabel.fontName = "AmericanTypewriter-Bold"
        lifeLabel.fontColor = SKColor.white
        
        menuButton = SKSpriteNode()
        menuButton.texture = SKTexture(imageNamed: "menu")
        menuButton.size = CGSize.init(width: 465, height: 119)
        menuButton.name = "menu"
        menuButton.zPosition = 4
        menuButton.position = CGPoint(x:0, y:-237)
 
        
        self.addChild(lifeLabel)
        self.addChild(scoreLabel)
        var size = CGSize(width: 20, height: 20)
        if UserDefaults.standard.bool(forKey: "hard") {
                size = CGSize(width: 200, height: 200)
                sizeMinAlien = CGFloat(20)
        }
        self.childNode(withName: "alien")?.physicsBody?.categoryBitMask = alienCategory
        self.childNode(withName: "alien")?.physicsBody?.contactTestBitMask = torpedoCategory
        self.childNode(withName: "alien-1")?.physicsBody?.categoryBitMask = alienCategory
        self.childNode(withName: "alien-1")?.physicsBody?.contactTestBitMask = torpedoCategory
        (self.childNode(withName: "alien-1") as! SKSpriteNode).size = size
        
        self.childNode(withName: "alien-2")?.physicsBody?.categoryBitMask = alienCategory
        self.childNode(withName: "alien-2")?.physicsBody?.contactTestBitMask = torpedoCategory
        self.childNode(withName: "soldier")?.physicsBody?.categoryBitMask = soldierCategory
        self.childNode(withName: "soldier")?.physicsBody?.contactTestBitMask = alienCategory
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
    }
    
    //Criéé un  corp (un Noeud) 
    func createBody(name: String, cat: UInt32, col: UInt32, cont: UInt32, pos:CGPoint, size: CGSize,
                    velocity: CGVector, color: NSColor, img: String ){
        
        var body = SKSpriteNode(color: color, size: size)
        
        body = SKSpriteNode(texture: SKTexture.init(imageNamed: img), size: size)

        body.position = CGPoint(x: pos.x, y: pos.y)
        body.zPosition = 2
        body.name = name
        body.physicsBody = SKPhysicsBody(rectangleOf: body.size)
        body.physicsBody?.linearDamping = 0
        body.physicsBody?.isDynamic = true
        body.physicsBody?.categoryBitMask = cat
        body.physicsBody?.collisionBitMask = col
        body.physicsBody?.contactTestBitMask = cont
        self.addChild(body)
        
        body.physicsBody?.velocity = velocity
    }
    
    //reaction a la collision entre vaiseau et alien
    func reactionAlienSoldier(alien: SKSpriteNode, soldier: SKSpriteNode){
        
        let pos = soldier.position
        explosion(pos: pos)
        life -= 1
        if life < 60 && life > 40 {
            lifeLabel.fontColor = NSColor.init(red: 255, green: 68, blue: 0, alpha: 1)
            (childNode(withName: "life") as! SKSpriteNode).color = NSColor.init(red: 255, green: 68, blue: 0, alpha: 1)
        }
        if life <= 40 && life > 0 {
            lifeLabel.fontColor = NSColor.orange
            (childNode(withName: "life") as! SKSpriteNode).color = NSColor.orange
        }
        if life <= 20 {
            lifeLabel.fontColor = NSColor.red
            (childNode(withName: "life") as! SKSpriteNode).color = NSColor.red
        }
        if life <= 0 {
            
            let gameOver = SKLabelNode.init(text: "GAME OVER")
            gameOver.fontSize = 80
            gameOver.fontName = "AmericanTypewriter-Bold"
            gameOver.fontColor = NSColor.red
            gameOver.zPosition = 4
            gameOver.position = CGPoint(x: 0, y: 0)
            self.addChild(gameOver)
            self.childNode(withName: "soldier")?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.addChild(menuButton)
        }
    }

    //reaction a la colusion body et balle
    func reactionAlienTorpedo(torpidoNode: SKSpriteNode, alienNode: SKSpriteNode) {

        var pos = alienNode.position
        explosion(pos: CGPoint(x: pos.x - (alienNode.size.width/2), y: pos.y))
        
        switch size {
        
        case CGSize(width: 60.0, height: 60.0):
            score += 2
        
        case CGSize(width: 50.0, height: 50.0):
            score += 2
            
        case CGSize(width: 30.0, height: 30.0):
            score += 4
            
        case CGSize(width: 25.0, height: 25.0):
            score += 4
            
        case CGSize(width: 15.0, height: 15.0):
            score += 4
            
        case CGSize(width: 12.5, height: 12.5):
            score += 6
            
        default:
            score += 1
        }
        
        if alienNode.size.width >= sizeMinAlien{
            
            let w = alienNode.size.width / CGFloat(2)
            let h = alienNode.size.height / CGFloat(2)
            let size = CGSize(width: w, height: h)
        
            //Dupliquer l'alien en plusueurs de taille plus petite
            if(alienNode.size.width >= CGFloat(100)){
            
                createBody(name: "alien", cat: alienCategory, col: 0, cont: torpedoCategory, pos:pos, size: size,velocity: CGVector(dx: -90, dy: 70), color: NSColor.gray,img: "Image-1")
            
                createBody(name: "alien", cat: alienCategory, col: 0, cont: torpedoCategory, pos:pos, size: size,velocity: CGVector(dx: -70, dy: -90), color: NSColor.gray, img: "Image-1")
            }
        
            pos.y = pos.y+(h/2)
            createBody(name: "alien", cat: alienCategory, col: 0, cont: torpedoCategory, pos:pos, size: size, velocity: CGVector(dx: -100, dy: 90), color: NSColor.gray, img: "Image-1")
            pos.y = pos.y-(h)
            createBody(name: "alien", cat: alienCategory, col: 0, cont: torpedoCategory, pos:pos, size:
                size, velocity: CGVector(dx: -100, dy: -100),  color: NSColor.gray, img: "Image-1")
        }
        torpidoNode.removeFromParent()
        alienNode.removeFromParent()
        
        if self.childNode(withName: "alien") == nil {
            let wow = SKLabelNode.init(text: "WOUAHH... BRAVO!.")
            wow.fontSize = 80
            wow.fontName = "AmericanTypewriter-Bold"
            wow.fontColor = NSColor.green
            wow.zPosition = 4
            wow.position = CGPoint(x: 0, y: 0)
            self.addChild(wow)
            self.childNode(withName: "soldier")?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
            self.addChild(menuButton)
        }
    }
    
    //avncer un corp
    func move_up(body_name: String){
        let body = self.childNode(withName: body_name) as? SKSpriteNode
        let x = 100*cos(body!.zRotation)
        let y = 100*sin(body!.zRotation)
        
        body?.physicsBody?.velocity.dx += x
        body?.physicsBody?.velocity.dy += y
    }
    
    //arreter un corp (freiner)
    func stop_body(body_name: String){
        let body = self.childNode(withName: body_name) as? SKSpriteNode
        if((body?.physicsBody!.velocity.dx)! > CGFloat(0.0)){
            body?.physicsBody?.velocity.dx -= 10
        } else {
            body?.physicsBody?.velocity.dx += 10
        }
        
        if((body?.physicsBody!.velocity.dy)! > CGFloat(0.0)){
            body?.physicsBody?.velocity.dy -= 10
        } else {
            body?.physicsBody?.velocity.dy += 10
        }
    }
    
    //tourner a gauche ou a droit
    func rotate(body_name: String, side: Character) {
        if(side == "L"){
            self.childNode(withName: body_name)?.zRotation += 0.2
        }
        if(side == "R"){
            self.childNode(withName: body_name)?.zRotation -= 0.2
        }
    }
    
    //afficher un effet d'une explosion
    func explosion(pos: CGPoint) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")!
        explosion.position = pos
        explosion.zPosition = 3
        
        self.addChild(explosion)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        self.run(SKAction.wait(forDuration: 2)){
            explosion.removeFromParent()
        }
    }
    
    //Debut de collision
    func didBegin(_ contact: SKPhysicsContact) {
        if life > 0 {
            var firstBody: SKPhysicsBody
            var secondeBody: SKPhysicsBody
        
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                firstBody = contact.bodyA
                secondeBody = contact.bodyB
            }else {
                firstBody = contact.bodyB
                secondeBody = contact.bodyA
            }
        
            //Contact entre l'alien et le torpedo (la balle)
            if (firstBody.categoryBitMask & alienCategory) != 0 && (secondeBody.categoryBitMask & torpedoCategory) != 0 {
            
                if firstBody.node != nil && secondeBody.node != nil {
                    if scorInit {
                        scorInit = false
                        self.childNode(withName: "score-init")?.removeFromParent()
                    }
                    reactionAlienTorpedo(torpidoNode: secondeBody.node as! SKSpriteNode, alienNode: firstBody.node as! SKSpriteNode)
                }
            }
            //contact entre l'alien et le vaisseau
            if (firstBody.categoryBitMask & alienCategory) != 0 && (secondeBody.categoryBitMask & soldierCategory) != 0 {
            
                if firstBody.node != nil && secondeBody.node != nil {
                    if lifeInit {
                        lifeInit = false
                        self.childNode(withName: "life-init")?.removeFromParent()
                    }
                    reactionAlienSoldier(alien: firstBody.node as! SKSpriteNode, soldier: secondeBody.node as! SKSpriteNode)
                }
            }
        }
    }
    
    //Fin de la collision
    func didEnd(_ contact: SKPhysicsContact) {
    }
    
    //Ecouter un clic de souri
    func touchUp(atPoint pos : CGPoint) {
        let nodesArray = self.nodes(at: pos)
        
        if nodesArray.first?.name == "menu" {
            let transition = SKTransition.doorsCloseHorizontal(withDuration: 0.5)
            if let scene = GKScene(fileNamed: "MenuScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! MenuScene? {
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    view?.presentScene(sceneNode, transition: transition)
                }
            }
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    //Ecouter un clic sur un bouton
    override func keyDown(with event: NSEvent) {
        if life > 0 && self.childNode(withName: "alien") != nil {
            switch event.keyCode {
             case 0x31:
                 //tirer une balle
                 self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
                 let soldier = self.childNode(withName: "soldier")
                 let pos = soldier!.position
                 let size = CGSize(width: 11.0, height: 11.0)
                 let x = 900*cos(soldier!.zRotation)
                 let y = 900*sin(soldier!.zRotation)
                 let velocity  = CGVector(dx: x, dy: y)
            
                 createBody(name: "torpedo", cat: torpedoCategory, col: 0, cont: alienCategory, pos:pos, size:    size, velocity: velocity, color: NSColor.blue, img: "torpedo")
            
             case 0x7b:
                 //tourner à gauche
                 rotate(body_name: "soldier", side: "L")
            
             case 0x7e:
                 //avancer
                 move_up(body_name: "soldier")
            
             case 0x7c:
                 //tourner à droit
                 rotate(body_name: "soldier", side: "R")
             case 0x7d:
                 //freiner le vaiseau
                 stop_body(body_name: "soldier")
            
             default:
                print("keyDown: \(event.characters!) keyCode: \(event.keyCode)")
                print(" Cette touche n'est pas programmer :(. \n")
                print("utilisez les 5 touches: <  > /\\ \\/ et espace.")
            }
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        for node in self.children{
            
            if(node.position.x > (self.size.width/2)){
                if(node.name == "torpedo"){
                    self.childNode(withName: "torpedo")?.removeFromParent()
                }else {
                    node.position.x = -(self.size.width/2)
                }
            }
            
            if(node.position.x < -(self.size.width/2)){
                if(node.name == "torpedo"){
                    self.childNode(withName: "torpedo")?.removeFromParent()
                }else{
                    node.position.x = (self.size.width/2)
                }
            }
            
            if(node.position.y > (self.size.height/2)){
                if(node.name == "torpedo"){
                    self.childNode(withName: "torpedo")?.removeFromParent()
                }else{
                    node.position.y = -(self.size.height/2)
                }
            }
            if(node.position.y < -(self.size.height/2)){
                
                if(node.name == "torpedo"){
                    self.childNode(withName: "torpedo")?.removeFromParent()
                }else{
                    node.position.y = (self.size.height/2)
                }
            }
        }
    }
}
