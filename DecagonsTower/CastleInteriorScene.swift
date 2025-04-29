import AVFoundation
import SpriteKit
import GameplayKit

class CastleInteriorScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    var enemyNPC: SKSpriteNode!
    var battleZone: SKNode!
    var inBattleZone = false
    var castleAudioEngine: AVAudioEngine!
    var castleMusicPlayer: AVAudioPlayerNode!
    var castleMusicFile: AVAudioFile!

    let showCards: (Bool) -> Void
    
    private var cameraNode = SKCameraNode()
    private var movementDirection: CGVector?
    
    var hasHealingCard: Bool = false
    var inventory: [String: Bool] = [:]

    init(size: CGSize, hasHealingCard: Bool, showCards: @escaping (Bool) -> Void) {
        self.hasHealingCard = hasHealingCard
        self.showCards = showCards
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMove(to view: SKView) {
        playCastleMusic ()
        func playCastleMusic() {
            do {
                guard let url = Bundle.main.url(forResource: "castle_music_Akatsuki_Naruto", withExtension: "mp3") else {
                    print("Castle music file not found")
                    return
                }

                castleMusicFile = try AVAudioFile(forReading: url)

                castleAudioEngine = AVAudioEngine()
                castleMusicPlayer = AVAudioPlayerNode()
                castleAudioEngine.attach(castleMusicPlayer)

                let mixer = castleAudioEngine.mainMixerNode
                castleAudioEngine.connect(castleMusicPlayer, to: mixer, format: castleMusicFile.processingFormat)

                try castleAudioEngine.start()

                castleMusicPlayer.scheduleFile(castleMusicFile, at: nil, completionHandler: nil)
                castleMusicPlayer.volume = 0.4 // adjust volume as needed
                castleMusicPlayer.play()

            } catch {
                print("Error playing castle music: \(error)")
            }
        }

        // SKCameraNode used to set camera on player character
        setUpCamera()
        
        backgroundColor = .darkGray
        physicsWorld.contactDelegate = self
        
        addBackgroundImage(name: "InsideCastle")
        setupPlayer(contactTestBitMask: PhysicsCategory.wolf | PhysicsCategory.interactionZone)
        setUpEnemyKnight()
        setUpBattleZone()
        
        inventory = [
            "Hit": true,
            "Repel": true,
            "Healing": hasHealingCard,
            "Laser": true
        ]
    }
    
    private func setUpCamera(scale: Double = 0.75) {
        cameraNode = SKCameraNode()
        camera = cameraNode
        cameraNode.name = "Camera"
        addChild(cameraNode)
        cameraNode.setScale(scale)
    }

    func addBackgroundImage(name: String) {
        let background = SKSpriteNode(imageNamed: name) // Make sure "map" is added to Assets
        background.name = "Background"
        background.position = CGPoint(x: size.width / 2, y: size.height / 2)
        background.size = CGSize(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height )
        background.zPosition = -10
        addChild(background)
    }

    func setupPlayer(contactTestBitMask: UInt32) {
        let firstFrame = Player.loadIdleFrames().first ?? SKTexture()
        player = Player(texture: firstFrame, color: .clear, size: CGSize(width: 125, height: 125))
        player.position = CGPoint(x: size.width / 2, y: 60)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 5.0
        player.physicsBody?.categoryBitMask =  PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = contactTestBitMask
        player.name = "Player"
        addChild(player)
        player.setIdleAnimation()
    }
    
    func setUpEnemyKnight() {
        enemyNPC = SKSpriteNode(imageNamed: "enemyKnight") // Make sure "Wolf" is added to Assets
        enemyNPC.size = CGSize(width: 50, height: 50)
        enemyNPC.position = CGPoint(x: size.width / 2, y: 410)
        enemyNPC.name = "Enemy Night"
        enemyNPC.zPosition = 10
        enemyNPC.physicsBody = SKPhysicsBody(rectangleOf: enemyNPC.size)
        enemyNPC.physicsBody?.isDynamic = false
        enemyNPC.physicsBody?.categoryBitMask = PhysicsCategory.enemyKnight
        enemyNPC.physicsBody?.contactTestBitMask = PhysicsCategory.player
        enemyNPC.name = "Enemy Knight"
        addChild(enemyNPC)
    }

    func setUpBattleZone() {
        battleZone = SKSpriteNode(color: .clear, size: .init(width: 30, height: 30))
        battleZone.position = CGPoint(x: size.width / 2, y: 310)
        battleZone.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        battleZone.physicsBody?.isDynamic = false
        battleZone.physicsBody?.categoryBitMask = PhysicsCategory.interactionZone
        battleZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        battleZone.physicsBody?.collisionBitMask = 0
        battleZone.zPosition = -1
        battleZone.name = "Battle Zone"
        addChild(battleZone)
        
        let label = SKLabelNode(text: "Enter the battle zone")
        label.position = CGPoint(x: size.width / 2, y: 220)
        label.fontSize = 20.0
        label.numberOfLines = 1
        addChild(label)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, !inBattleZone else { return }

        let position = touch.location(in: self)
            
        let currentPosition = player.position
        
        var dx = position.x - currentPosition.x
        var dy = position.y - currentPosition.y
        
        let length = sqrt(dx * dx + dy * dy)
        dx = dx / length
        dy = dy / length
        
        let alpha: CGFloat = 20
        let maxDelta: CGFloat = 300
        
        dx = dx * alpha
        dy = dy * alpha
        
        var finalDX = dx
        if abs(dx) > maxDelta {
            finalDX = maxDelta * (dx > 0 ? 1 : -1)
        }
        var finalDY = dy
        if abs(dy) > maxDelta {
            finalDY = maxDelta * (dy > 0 ? 1 : -1)
        }
        
        movementDirection = nil
        player.setWalkAnimation()
        player.physicsBody?.applyImpulse(.init(dx: finalDX, dy: finalDY))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)
        movePlayerToward(touch.location(in: self))

        if inBattleZone {
//            if node.name == "Choice_Correct" {
//                correctAnswers += 1
//                riddleIndex += 1
//                presentRiddle()
//            } else if node.name == "Choice_Wrong" {
//                riddleIndex += 1
//                presentRiddle()
//            }
        }
    }
    
    // Used for player movement
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        movePlayerToward(touch.location(in: self))
    }
    
    // Helper function used for player movement
    private func movePlayerToward(_ location: CGPoint) {
        let direction = CGVector(dx: location.x - player.position.x, dy: location.y - player.position.y)
        let length = sqrt(direction.dx * direction.dx + direction.dy * direction.dy)
        
        guard length > 0 else { return }
        
        let normalized = CGVector(dx: direction.dx / length, dy: direction.dy / length)
        movementDirection = normalized
    }

    func didBegin(_ contact: SKPhysicsContact) {
//        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
//        if names.contains("WolfNPC") && !inRiddle {
//            presentRiddle()
//        }
//        showCards(true)
//            let nextScene = CastleInteriorScene(size: view.bounds.size, hasHealingCard: rewardHealing)
//            nextScene.scaleMode = .resizeFill
//            view.presentScene(nextScene, transition: .doorway(withDuration: 1.0))
        if let view = self.view, let viewController = view.window?.rootViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as? BattleViewController {
                    battleVC.modalPresentationStyle = .fullScreen
                    viewController.present(battleVC, animated: true, completion: nil)
                }
            }
    }

    // Update function used if player is walking or idling based on physicsBody velocity
    override func update(_ currentTime: TimeInterval) {
        let velocity = player.physicsBody?.velocity ?? .zero
        let speed = hypot(velocity.dx, velocity.dy)

        if speed < 10 {
            player.stopWalking()
        } else {
            player.setWalkAnimation()
        }
        
        // Holding on direction allows player to keep moving
        if let direction = movementDirection {
            let speed: CGFloat = 100
            player.physicsBody?.velocity = CGVector(dx: direction.dx * speed, dy: direction.dy * speed)
            player.setWalkAnimation()
        } else {
            let velocity = player.physicsBody?.velocity ?? .zero
            let speed = hypot(velocity.dx, velocity.dy)
            if speed < 10 {
                player.stopWalking()
                player.physicsBody?.velocity = .zero
            }
        }
        
        // Camera follows the player
        let lerpFactor: CGFloat = 0.1
        let targetCameraPosition = player.position
        let newPosition = CGPoint(
            x: cameraNode.position.x + (targetCameraPosition.x - cameraNode.position.x) * lerpFactor,
            y: cameraNode.position.y + (targetCameraPosition.y - cameraNode.position.y) * lerpFactor
        )
        cameraNode.position = newPosition
    }
}
