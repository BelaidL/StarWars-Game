/******************************************************************
*                                                                 *
*    GameScene.swift                                              *
*    StarWars                                                     *
*                                                                 *
*    Created by lagha on 09/03/2018.                              *
*    Copyright © 2018 lagha. All rights reserved.                 *
*                                                                 *
*******************************************************************/


import SpriteKit
import GameplayKit

class MenuScene: SKScene {

    var newGameButtonNode: SKSpriteNode!
    var difficaltyButtonNode: SKSpriteNode!
    var difficaltyLabelnode: SKLabelNode!
    
    override func sceneDidLoad() {
     
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        difficaltyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        difficaltyLabelnode = self.childNode(withName: "difficultyLabel") as! SKLabelNode
        
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "hard") {
            difficaltyLabelnode.text = "Hard"
        }else {
            difficaltyLabelnode.text = "Easy"
        }
        
    }
    
   
    func touchUp(atPoint pos : CGPoint) {
        let nodesArray = self.nodes(at: pos)
        
        if nodesArray.first?.name == "newGameButton" {
            let transition = SKTransition.flipVertical(withDuration: 0.5)
            if let scene = GKScene(fileNamed: "GameScene") {
                
                // Get the SKScene from the loaded GKScene
                if let sceneNode = scene.rootNode as! GameScene? {
                    
                    // Set the scale mode to scale to fit the window
                    sceneNode.scaleMode = .aspectFill
                    
                    // Present the scene
                    view?.presentScene(sceneNode, transition: transition)
                }
            }
        }else if nodesArray.first?.name == "difficultyButton" {
            changeDifficulty()
        }
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
    func changeDifficulty(){
        let userDefault = UserDefaults.standard
        
        if difficaltyLabelnode.text == "Easy" {
            difficaltyLabelnode.text = "Hard"
            userDefault.set(true, forKey: "hard")
        }else {
            difficaltyLabelnode.text = "Easy"
            userDefault.set(false, forKey: "hard")
        }
    }
    
    
}
