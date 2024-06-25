//
//  GameOverScene.swift
//  CatchFishy
//
//  Created by Thush-Fdo on 25/06/2024.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    override init(size: CGSize) {
        super.init(size: size)
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = frame.size
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.zPosition = -0.5
        addChild(background)
        
        
        let gameOver = SKSpriteNode(imageNamed: "gameover")
        gameOver.position = CGPoint(x: frame.midX, y: frame.midY + 120)
        addChild(gameOver)
        
        let label = SKLabelNode(fontNamed: "HelveticaNeue-Medium")
        label.text = "Your Score : \(GameScene.score)"
        label.fontSize = 40
        label.fontColor = SKColor.black
        label.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(label)
        
        let replayMessage = "Replay"
        let replayButton = SKLabelNode(fontNamed: "HelveticaNeue-CondensedBlack")
        replayButton.text = replayMessage
        replayButton.fontColor = SKColor.black
        replayButton.position = CGPointMake(self.size.width/2, 50)
        replayButton.name = "replay"
        self.addChild(replayButton)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            let location = touch.location(in: self)
            let node = self.atPoint(location)
            if node.name == "replay" {
                if let scene = GameScene(fileNamed: "GameScene") {
                    scene.scaleMode = .aspectFill
                    let transition = SKTransition.flipHorizontal(withDuration: 0.5)
                    view?.presentScene(scene, transition: transition)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
