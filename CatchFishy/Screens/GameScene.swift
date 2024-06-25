//
//  GameScene.swift
//  CatchFishy
//
//  Created by Thush-Fdo on 24/06/2024.
//

import SpriteKit
import GameplayKit

enum GameState {
    case showingLogo
    case playing
    case over
}

class GameScene: SKScene {
    
    private var scoreLabel: SKLabelNode?
    private var timerLabel: SKLabelNode?
    
    var logo: SKSpriteNode!
    var backgroundMusic: SKAudioNode!
    
    static var score = 0
    var timer = 0
    let timeLimit = 30
    var fishList: [TankSprite] = []
    var bonesList: [TankSprite] = []
    
    var gameState = GameState.showingLogo
    let explode = SKAction.scale(by: 0.25, duration: 0.2)
    
    
    override func didMove(to view: SKView) {
        configureScene()
        setBackgroundMusic()
    }
    
    func configureScene() {
        
        timer = timeLimit
        
        let topLeftInView = CGPoint(x: 30, y: 20)
        let topLeft = convertPoint(fromView: topLeftInView)
        timerLabel = childNode(withName: "//timerLabel") as? SKLabelNode
        timerLabel?.position = topLeft
        timerLabel?.text = "Timer: \(timer)s"
        
        guard let view = self.view else {
            return
        }
        
        let topRightInView = CGPoint(x: view.bounds.maxX - 30, y: 20)
        let topRight = convertPoint(fromView: topRightInView)
        scoreLabel = childNode(withName: "//scoreLabel") as? SKLabelNode
        scoreLabel?.position = topRight
        
        logo = SKSpriteNode(imageNamed: "logo")
        logo.position = CGPoint(x: frame.midX, y: frame.midY)
        logo.scale(to: CGSize(width: view.bounds.width, height: view.bounds.height))
        addChild(logo)
    }
    
    func setBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "sunny", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic.run(SKAction.changeVolume(to: 0.3, duration: 0.1))
            addChild(backgroundMusic)
        }
    }
    
    func stopBackgroundMusic() {
        guard let backgroundMusic = backgroundMusic else { return }
        backgroundMusic.run(SKAction.changeVolume(to: 0.1, duration: 0.05))
        backgroundMusic.run(SKAction.stop())
    }
    
    func spawnTankSprites() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run ( spawnFish ),
            SKAction.run ( spawnBones ),
            SKAction.wait(forDuration: 0.5, withRange: 0.1)
        ])))
    }
    
    func spawnFish() {
        fishList = [
            TankSprite.init(name: "fish0", imageURL: "fish0", speed: 250, score: 5),
            TankSprite.init(name: "fish1", imageURL: "fish1", speed: 300, score: 10),
            TankSprite.init(name: "fish2", imageURL: "fish2", speed: 350, score: 15),
            TankSprite.init(name: "fish3", imageURL: "fish3", speed: 450, score: 20)
        ]
        
        let fishIndex = Int.random(in: 0...3)
        setMove(to: fishList[fishIndex])
    }
    
    func spawnBones() {
        bonesList = [
            TankSprite.init(name: "afish0", imageURL: "afish0", speed: 250, score: 5),
            TankSprite.init(name: "afish1", imageURL: "afish1", speed: 300, score: 10),
            TankSprite.init(name: "afish2", imageURL: "afish2", speed: 350, score: 15),
            TankSprite.init(name: "afish3", imageURL: "afish3", speed: 450, score: 20)
        ]
        
        let boneIndex = Int.random(in: 0...3)
        setMove(to: bonesList[boneIndex])
    }
    
    func setMove(to tankSprite: TankSprite) {
        let sprite = SKSpriteNode(imageNamed: tankSprite.imageURL)
        sprite.name = tankSprite.name
        
        let movesLeftToRight = Bool.random()
        let randomY = CGFloat.random(in: 0...size.height - sprite.size.height)
        let fishY = randomY - size.height / 2 + sprite.size.height / 2
        
        if movesLeftToRight {
            let fishX = -size.width / 2 - sprite.size.width / 2
            sprite.position = CGPoint(x: fishX, y: fishY)
        } else {
            let fishX = size.width / 2 + sprite.size.width / 2
            sprite.position = CGPoint(x: fishX, y: fishY)
            sprite.xScale = -1
        }
        sprite.zPosition = 1
        addChild(sprite)
        
        let distance = size.width + sprite.size.width
        let speed = CGFloat(tankSprite.speed)
        let duration = distance / speed
        
        let directionFactor: CGFloat = movesLeftToRight ? 1 : -1
        let moveAction = SKAction.moveBy(x: distance * directionFactor, y: 0, duration: TimeInterval(duration))
        let removeAction = SKAction.removeFromParent()
        
        sprite.run(SKAction.sequence([moveAction, removeAction]))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        switch gameState {
        case .showingLogo:
            gameState = .playing
            
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let wait = SKAction.wait(forDuration: 0.5)
            let activatePlayer = SKAction.run { [unowned self] in
                self.startTImer()
                self.spawnTankSprites()
            }
            
            let sequence = SKAction.sequence([fadeOut, wait, activatePlayer, remove])
            logo.run(sequence)
            
        case .playing:
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let tappedNode = atPoint(location)
            
            gamePlay(for: tappedNode)
            
        case .over:
            if let scene = GameScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                let transition = SKTransition.moveIn(with: SKTransitionDirection.right, duration: 1)
                view?.presentScene(scene, transition: transition)
            }
        }
    }
    
    func gamePlay(for tappedNode: SKNode) {
        if let tappedSprite = fishList.filter({ $0.name == tappedNode.name }).first {
            tappedNode.run(explode, completion: {
                tappedNode.removeFromParent()
            })
            GameScene.score += tappedSprite.score
        }
        
        if let tappedSprite = bonesList.filter({ $0.name == tappedNode.name }).first {
            tappedNode.run(explode, completion: {
                tappedNode.removeFromParent()
            })
            GameScene.score -= tappedSprite.score
        }
        
        scoreLabel?.text = "Score: \(GameScene.score)"
    }
    
    func startTImer() {
        let counterDecrement = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run(countdownAction)
        ])
        
        run(
            SKAction.sequence([
                SKAction.repeat(counterDecrement, count: timeLimit),
                SKAction.run(endCountdown)
            ])
        )
        
    }
    
    func countdownAction() {
        timer -= 1
        timerLabel?.text = "Timer: \(timer)s"
    }
    
    func endCountdown() {
        GameScene.score = 0
        scoreLabel?.text = "Score: 0"
        gameState = .over
        stopBackgroundMusic()
        showGameOver()
    }
    
    func showGameOver() {
        let reveal = SKTransition.flipHorizontal(withDuration: 0.5)
        let scene = GameOverScene(size: self.size)
        self.view?.presentScene(scene, transition: reveal)
    }
}
