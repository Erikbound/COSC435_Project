import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    var wolfNPC: SKSpriteNode!
    var riddleZone: SKNode!
    var riddleUI: SKNode?
    var inRiddle = false
    var riddleIndex = 0
    var correctAnswers = 0
    var castle: SKShapeNode!
    var backgroundMusic: SKAudioNode?
    
    private var cameraNode = SKCameraNode()
    private var movementDirection: CGVector?

    let riddles: [(question: String, correct: String, wrong: String)] = [
        ("What has to be broken before you can use it?", "An egg", "A clock"),
        ("What goes up but never comes down?", "Your age", "A balloon"),
        ("I’m tall when I’m young, and I’m short when I’m old. What am I?", "A candle", "A pencil")
    ]

    override func didMove(to view: SKView) {
        // SKCameraNode used to set camera on player character
        super.didMove(to: view)
        cameraNode = SKCameraNode()
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.setScale(0.75) // Zooms in slightly
        
        backgroundColor = .black
        physicsWorld.contactDelegate = self

        addMapBackground()
        setupPlayer()
        setupWolf()
        setupRiddleZone()
        setupCastle()
        playBackgroundMusic()
    }

    func addMapBackground() {
        let map = SKSpriteNode(imageNamed: "Outside Map") // Make sure "map" is added to Assets
        map.position = CGPoint(x: size.width / 2, y: size.height / 2)
        map.size = CGSize(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height )
        map.zPosition = -10
        addChild(map)
        
        // Adds boundaries to map so player can't walk out of bound
        let border = SKPhysicsBody(edgeLoopFrom: map.frame)
        border.categoryBitMask = PhysicsCategory.obstacle
        border.contactTestBitMask = PhysicsCategory.player
        border.collisionBitMask = PhysicsCategory.player
        border.friction = 0
        self.physicsBody = border
    }
    
    // Plays music while on the map
    func playBackgroundMusic() {
        guard let url = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") else { return }
        backgroundMusic = SKAudioNode(url: url)
        addChild(backgroundMusic!)
        backgroundMusic?.run(SKAction.play())
    }

    func setupPlayer() {
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
        player.physicsBody?.contactTestBitMask = PhysicsCategory.wolf |
        PhysicsCategory.interactionZone | PhysicsCategory.castle
        player.physicsBody?.collisionBitMask = PhysicsCategory.castle | PhysicsCategory.obstacle
        addChild(player)
        player.setIdleAnimation()
    }
    
    func setupCastle () {
        var rect = CGRect()
        rect.origin.x = UIScreen.main.bounds.width / 2 - 100
        rect.origin.y = UIScreen.main.bounds.height - 440
        rect.size = CGSize(width: 220, height: 370)
        let center = CGPoint(x:  UIScreen.main.bounds.width / 2 - 10, y: UIScreen.main.bounds.height - 440)
        let radius: CGFloat = 100
        let position1 = CGPoint(x: center.x, y: center.y + radius)
        let shape = SKShapeNode(ellipseIn: rect)
        
        shape.position = position1
        shape.fillColor = .red
        shape.strokeColor = .red
        shape.lineWidth = 5
        shape.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        shape.physicsBody?.node?.position = position1
        shape.physicsBody?.affectedByGravity = false
        shape.physicsBody?.categoryBitMask = PhysicsCategory.castle
        shape.physicsBody?.collisionBitMask = PhysicsCategory.player
        shape.physicsBody?.isDynamic = false
        addChild(shape)
        
        let shape2 = SKShapeNode(ellipseIn: rect)
        let position2 = CGPoint(x: position1.x, y: position1.y + 85)
        shape2.position = position2
        shape2.fillColor = .black
        shape2.strokeColor = .black
        shape2.lineWidth = 5
        shape2.physicsBody = SKPhysicsBody(circleOfRadius: radius)
        shape2.physicsBody?.node?.position = position2
        shape2.physicsBody?.affectedByGravity = false
        shape2.physicsBody?.categoryBitMask = PhysicsCategory.castle
        shape2.physicsBody?.collisionBitMask = PhysicsCategory.player
        shape2.physicsBody?.isDynamic = false
        addChild(shape2)
           
    }
    
    func setupWolf() {
        wolfNPC = SKSpriteNode(imageNamed: "wolf") // Make sure "Wolf" is added to Assets
        wolfNPC.size = CGSize(width: 50, height: 50)
        wolfNPC.position = CGPoint(x: size.width / 2, y: 410)
        wolfNPC.name = "WolfNPC"
        wolfNPC.zPosition = 10
        wolfNPC.physicsBody = SKPhysicsBody(rectangleOf: wolfNPC.size)
        wolfNPC.physicsBody?.isDynamic = false
        wolfNPC.physicsBody?.categoryBitMask = PhysicsCategory.wolf
        wolfNPC.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(wolfNPC)

        // Simple wiggle animation
        let wiggleLeft = SKAction.moveBy(x: -40, y: 0, duration: 3.0)
        let wiggleRight = SKAction.moveBy(x: 40, y: 0, duration: 3.0)
        let flip = SKAction.run { [weak self] in
            self?.wolfNPC.xScale *= -1
        }
        let wiggle = SKAction.sequence([wiggleLeft, flip, wiggleRight, flip])
        wolfNPC.run(SKAction.repeatForever(wiggle))
    }

    func setupRiddleZone() {
        riddleZone = SKNode()
        riddleZone.position = CGPoint(x: size.width / 2, y: 305)
        riddleZone.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        riddleZone.physicsBody?.isDynamic = false
        riddleZone.physicsBody?.categoryBitMask = PhysicsCategory.interactionZone
        riddleZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        riddleZone.physicsBody?.collisionBitMask = 0
        riddleZone.zPosition = -1
        addChild(riddleZone)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else { return }
//        if inRiddle { return }
//
//        let target = touch.location(in: self)
//        let distance = hypot(player.position.x - target.x, player.position.y - target.y)
//        let speed: CGFloat = 100.0
//        let duration = TimeInterval(distance / speed)
//
//        if target.x < player.position.x {
//            player.xScale = -1
//        } else {
//            player.xScale = 1
//        }
//        
//        if !childNode(withName: "castle")!.frame.contains(target) {
//            let moveAction = SKAction.move(to: target, duration: duration)
//            player.run(moveAction)
//        }
        guard let touch = touches.first else { return }
        if inRiddle { return }

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

        if inRiddle {
            if node.name == "Choice_Correct" {
                correctAnswers += 1
                riddleIndex += 1
                presentRiddle()
            } else if node.name == "Choice_Wrong" {
                riddleIndex += 1
                presentRiddle()
            }
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
        let names = [contact.bodyA.node?.name, contact.bodyB.node?.name]
        if names.contains("WolfNPC") && !inRiddle {
            presentRiddle()
        }
    }

    func presentRiddle() {
        if riddleIndex >= riddles.count {
            endRiddleChallenge()
            return
        }

        inRiddle = true
        riddleUI?.removeFromParent()

        let riddle = riddles[riddleIndex]
        riddleUI = SKNode()
        riddleUI?.zPosition = 999

        let dimmer = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        dimmer.fillColor = .black
        dimmer.alpha = 0.6
        dimmer.zPosition = 998
        riddleUI?.addChild(dimmer)

        let background = SKShapeNode(rectOf: CGSize(width: 340, height: 240), cornerRadius: 10)
        background.fillColor = .black
        background.strokeColor = .white
        background.zPosition = 999
        riddleUI?.addChild(background)

        let questionLabel = SKLabelNode(text: riddle.question)
        questionLabel.fontSize = 16
        questionLabel.preferredMaxLayoutWidth = 300
        questionLabel.numberOfLines = 0
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.position = CGPoint(x: 0, y: 50)
        questionLabel.fontColor = .white
        questionLabel.zPosition = 1000
        riddleUI?.addChild(questionLabel)

        let choiceA = SKLabelNode(text: riddle.correct)
        choiceA.name = "Choice_Correct"
        choiceA.fontSize = 14
        choiceA.position = CGPoint(x: 0, y: 0)
        choiceA.fontColor = .white
        choiceA.zPosition = 1000
        riddleUI?.addChild(choiceA)

        let choiceB = SKLabelNode(text: riddle.wrong)
        choiceB.name = "Choice_Wrong"
        choiceB.fontSize = 14
        choiceB.position = CGPoint(x: 0, y: -40)
        choiceB.fontColor = .white
        choiceB.zPosition = 1000
        riddleUI?.addChild(choiceB)

        riddleUI?.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(riddleUI!)
    }

    func endRiddleChallenge() {
        inRiddle = false
        riddleUI?.removeFromParent()

        let rewardHealing = (correctAnswers == 3)
        let canEnter = (correctAnswers > 0)

        if canEnter, let view = self.view {
            let nextScene = CastleInteriorScene(
                size: view.bounds.size,
                hasHealingCard: rewardHealing,
                showCards: { _ in }
            )
            nextScene.scaleMode = .resizeFill
            view.presentScene(nextScene, transition: .doorway(withDuration: 1.0))
        }
        
        backgroundMusic?.run(SKAction.stop())
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
