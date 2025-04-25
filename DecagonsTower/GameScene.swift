import SpriteKit
import GameplayKit

class BaseScene: SKScene {
    
}


class GameScene: BaseScene, SKPhysicsContactDelegate {
    var player: Player!
    var wolfNPC: WolfNPC!
    var riddleZone: SKNode!
    var riddleUI: SKNode?
    var inRiddle = false
    var riddleIndex = 0
    var correctAnswers = 0
    var castle: SKShapeNode!
    var backgroundMusic: SKAudioNode?
    let showCards: (Bool) -> Void
    

    private var cameraNode = SKCameraNode()
    private var movementDirection: CGVector?
    private var targetLocation: CGPoint?
    private let walkSpeed: CGFloat = 100
    private var targetMarker: SKShapeNode?
    private var backgroundNode: SKSpriteNode?

    let riddles: [(question: String, correct: String, wrong: String)] = [
        ("What has to be broken before you can use it?", "An egg", "A clock"),
        ("What goes up but never comes down?", "Your age", "A balloon"),
        ("I’m tall when I’m young, and I’m short when I’m old. What am I?", "A candle", "A pencil")
    ]

    init(size: CGSize, showCards: @escaping (Bool) -> Void) {
        self.showCards = showCards
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        setupPathBarriersToCastle()
        camera = cameraNode
        addChild(cameraNode)
        cameraNode.setScale(0.75)
        backgroundColor = .black
        physicsWorld.contactDelegate = self

//        // 🔊 Play test sound here
//        run(SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false))

//        // ⏯️ Background music
//        if let musicURL = Bundle.main.url(forResource: "backgroundMusic", withExtension: "mp3") {
//            backgroundMusic = SKAudioNode(url: musicURL)
//            backgroundMusic?.autoplayLooped = true
//            addChild(backgroundMusic!)
//        }

        addMapBackground()
        setupPlayer()
        setupWolf()
        setupCastle()
        setupRiddleZone()
        setupTargetMarker()
    }

    func addMapBackground() {
        let mapHeight: CGFloat = 680
        let mapWidth: CGFloat = 400

        let map = SKSpriteNode(imageNamed: "Outside Map")
        map.size = CGSize(width: mapWidth, height: mapHeight)
        map.position = CGPoint(x: size.width / 2, y: mapHeight / 2)
        map.zPosition = -40
        addChild(map)
        backgroundNode = map

        let worldBounds = CGRect(x: -1000, y: -1000, width: 3000, height: 3000)
        self.physicsBody = SKPhysicsBody(edgeLoopFrom: worldBounds)
        self.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        self.physicsBody?.contactTestBitMask = PhysicsCategory.player
        self.physicsBody?.collisionBitMask = PhysicsCategory.player
        self.physicsBody?.friction = 0
    }

    func setupTargetMarker() {
        targetMarker = SKShapeNode(circleOfRadius: 10)
        targetMarker?.fillColor = .yellow
        targetMarker?.strokeColor = .orange
        targetMarker?.alpha = 0.8
        targetMarker?.zPosition = 1
        targetMarker?.isHidden = true
        addChild(targetMarker!)
    }

    func setupPlayer() {
        let firstFrame = Player.loadIdleFrames().first ?? SKTexture()
        player = Player(texture: firstFrame, color: .clear, size: CGSize(width: 125, height: 125))
        player.name = "Player"
        player.position = CGPoint(x: size.width / 2, y: 80)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(circleOfRadius: 35)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.linearDamping = 5.0
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.wolf | PhysicsCategory.interactionZone | PhysicsCategory.castle
        player.physicsBody?.collisionBitMask = PhysicsCategory.castle | PhysicsCategory.obstacle

        let playerOutline = SKShapeNode(circleOfRadius: 10)
        playerOutline.strokeColor = .cyan
        playerOutline.lineWidth = 2
        playerOutline.zPosition = player.zPosition + 1
        player.addChild(playerOutline)

        addChild(player)
        player.setIdleAnimation()
    }

    func setupWolf() {
        wolfNPC = WolfNPC()
        wolfNPC.name = "WolfNPC"
        wolfNPC.size = CGSize(width: 60, height: 60)
        wolfNPC.position = CGPoint(x: size.width / 2, y: (backgroundNode?.position.y ?? size.height / 2) + 55)
        wolfNPC.zPosition = 10
        wolfNPC.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 70, height: 70))
        wolfNPC.physicsBody?.isDynamic = false
        wolfNPC.physicsBody?.affectedByGravity = false
        wolfNPC.physicsBody?.allowsRotation = false
        wolfNPC.physicsBody?.categoryBitMask = PhysicsCategory.wolf
        wolfNPC.physicsBody?.contactTestBitMask = PhysicsCategory.player
        wolfNPC.physicsBody?.collisionBitMask = 0
        addChild(wolfNPC)

        let wiggleLeft = SKAction.moveBy(x: -40, y: 0, duration: 3.0)
        let wiggleRight = SKAction.moveBy(x: 40, y: 0, duration: 3.0)
        let flip = SKAction.run { [weak self] in self?.wolfNPC.xScale *= -1 }
        let wiggle = SKAction.sequence([wiggleLeft, flip, wiggleRight, flip])
        wolfNPC.run(SKAction.repeatForever(wiggle))
    }

    func setupRiddleZone() {
        riddleZone = SKShapeNode(rectOf: CGSize(width: 100, height: 100))
        riddleZone.position = CGPoint(x: size.width / 2 + 20, y: wolfNPC.position.y + 10)
        riddleZone.zPosition = 1

        if let shape = riddleZone as? SKShapeNode {
            shape.strokeColor = .yellow
            shape.lineWidth = 2
            shape.fillColor = .clear
        }

        riddleZone.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 400, height: 100))
        riddleZone.physicsBody?.isDynamic = false
        riddleZone.physicsBody?.categoryBitMask = PhysicsCategory.interactionZone
        riddleZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        riddleZone.physicsBody?.collisionBitMask = 0

        addChild(riddleZone)
    }

    func setupCastle() {
        let rect = CGRect(x: size.width / 2 - 100, y: 0, width: 220, height: 370)
        let centerY = backgroundNode?.position.y ?? size.height / 2
        let castleBaseY = centerY + 450

        let shape1 = SKShapeNode(ellipseIn: rect)
        shape1.name = "Castle 1"
        shape1.position = CGPoint(x: size.width / 2, y: castleBaseY)
        shape1.fillColor = .red
        shape1.strokeColor = .red
        shape1.lineWidth = 5
        shape1.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        shape1.physicsBody?.affectedByGravity = false
        shape1.physicsBody?.categoryBitMask = PhysicsCategory.castle
        shape1.physicsBody?.collisionBitMask = PhysicsCategory.player
        shape1.physicsBody?.isDynamic = false
        addChild(shape1)

        let shape2 = SKShapeNode(ellipseIn: rect)
        shape2.name = "Castle 2"
        shape2.position = CGPoint(x: size.width / 2, y: castleBaseY + 85)
        shape2.fillColor = .black
        shape2.strokeColor = .black
        shape2.lineWidth = 5
        shape2.physicsBody = SKPhysicsBody(circleOfRadius: 100)
        shape2.physicsBody?.affectedByGravity = false
        shape2.physicsBody?.categoryBitMask = PhysicsCategory.castle
        shape2.physicsBody?.collisionBitMask = PhysicsCategory.player
        shape2.physicsBody?.isDynamic = false
        addChild(shape2)

        let castleBarrier = SKShapeNode(ellipseOf: CGSize(width: 150, height: 200))
        castleBarrier.position = CGPoint(x: size.width / 2, y: wolfNPC.position.y + 90)
        castleBarrier.strokeColor = .red
        castleBarrier.lineWidth = 2
        castleBarrier.fillColor = .clear
        castleBarrier.physicsBody = SKPhysicsBody(edgeLoopFrom: castleBarrier.path!)
        castleBarrier.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        castleBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.player
        castleBarrier.zPosition = 2
        addChild(castleBarrier)
    }
    func setupPathBarriersToCastle() {
        let pathWidth: CGFloat = 140
        let mapTop = backgroundNode?.frame.maxY ?? size.height
        let mapBottom = backgroundNode?.frame.minY ?? 0
        let barrierHeight = mapTop - mapBottom

        // LEFT Barrier (with visible color)
        let leftBarrier = SKShapeNode(rectOf: CGSize(width: 4, height: barrierHeight))
        leftBarrier.position = CGPoint(x: (size.width / 2) - (pathWidth / 2) - 2, y: (mapTop + mapBottom) / 2)
        leftBarrier.fillColor = .red
        leftBarrier.strokeColor = .clear
        leftBarrier.alpha = 0.4
        leftBarrier.zPosition = 50
        leftBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 4, height: barrierHeight))
        leftBarrier.physicsBody?.isDynamic = false
        leftBarrier.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        leftBarrier.physicsBody?.collisionBitMask = PhysicsCategory.player
        leftBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(leftBarrier)

        // RIGHT Barrier (with visible color)
        let rightBarrier = SKShapeNode(rectOf: CGSize(width: 4, height: barrierHeight))
        rightBarrier.position = CGPoint(x: (size.width / 2) + (pathWidth / 2) + 2, y: (mapTop + mapBottom) / 2)
        rightBarrier.fillColor = .blue
        rightBarrier.strokeColor = .clear
        rightBarrier.alpha = 0.4
        rightBarrier.zPosition = 50
        rightBarrier.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 4, height: barrierHeight))
        rightBarrier.physicsBody?.isDynamic = false
        rightBarrier.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        rightBarrier.physicsBody?.collisionBitMask = PhysicsCategory.player
        rightBarrier.physicsBody?.contactTestBitMask = PhysicsCategory.player
        addChild(rightBarrier)
    }

    

    func presentRiddle() {
        inRiddle = true
        wolfNPC.removeAllActions()
        riddleUI?.removeFromParent()
        player.physicsBody?.velocity = .zero
        targetLocation = nil
        player.stopWalking()

        // 🔉 Fade background music volume down
        backgroundMusic?.run(SKAction.changeVolume(to: 0.2, duration: 0.5))

        if riddleIndex >= riddles.count {
            endRiddleChallenge()
            return
        }
    


        let riddle = riddles[riddleIndex]
        riddleUI = SKNode()
        riddleUI?.zPosition = 1000

        // Bright overlay
        let dim = SKShapeNode(rectOf: CGSize(width: size.width, height: size.height))
        dim.fillColor = .black
        dim.alpha = 0.4 // Lower alpha keeps it visible but not overpowering
        dim.zPosition = 999
        riddleUI?.addChild(dim)


        // Box container
        let box = SKShapeNode(rectOf: CGSize(width: 350, height: 260), cornerRadius: 18)
        box.fillColor = .black
        box.strokeColor = .white
        box.lineWidth = 3
        box.position = .zero
        riddleUI?.addChild(box)

        // Riddle Question
        let question = SKLabelNode(text: riddle.question)
        question.fontName = "AvenirNext-Bold"
        question.fontSize = 22
        question.fontColor = .white
        question.position = CGPoint(x: 0, y: 70)
        question.numberOfLines = 0
        question.preferredMaxLayoutWidth = 320
        question.verticalAlignmentMode = .center
        question.horizontalAlignmentMode = .center
        riddleUI?.addChild(question)

        // Correct Answer
        let correct = SKLabelNode(text: riddle.correct)
        correct.name = "Choice_Correct"
        correct.fontName = "AvenirNext-Bold"
        correct.fontSize = 20
        correct.fontColor = .white
        correct.position = CGPoint(x: 0, y: 20)
        riddleUI?.addChild(correct)

        // Wrong Answer
        let wrong = SKLabelNode(text: riddle.wrong)
        wrong.name = "Choice_Wrong"
        wrong.fontName = "AvenirNext-Bold"
        wrong.fontSize = 20
        wrong.fontColor = .white
        wrong.position = CGPoint(x: 0, y: -30)
        riddleUI?.addChild(wrong)

        // Position UI in center of camera
        riddleUI?.position = .zero
        cameraNode.addChild(riddleUI!)
    }

    func endRiddleChallenge() {
        inRiddle = false
        riddleUI?.removeFromParent()

        if correctAnswers == 0 {
            // ❌ Player failed all riddles — show message
            let warningBox = SKNode()
            warningBox.zPosition = 1001
            warningBox.alpha = 0

            let background = SKShapeNode(rectOf: CGSize(width: 360, height: 80), cornerRadius: 14)
            background.fillColor = .black
            background.strokeColor = .red
            background.lineWidth = 3
            warningBox.addChild(background)

            let warningLabel = SKLabelNode(text: "You need at least one correct answer to enter")
            warningLabel.fontName = "AvenirNext-Bold"
            warningLabel.fontSize = 18
            warningLabel.fontColor = .white
            warningLabel.numberOfLines = 0
            warningLabel.preferredMaxLayoutWidth = 320
            warningLabel.verticalAlignmentMode = .center
            warningLabel.horizontalAlignmentMode = .center
            warningLabel.position = .zero
            warningBox.addChild(warningLabel)

            warningBox.position = CGPoint(x: 0, y: 0)
            cameraNode.addChild(warningBox)

            let appear = SKAction.fadeIn(withDuration: 0.2)
            let wait = SKAction.wait(forDuration: 2.2)
            let disappear = SKAction.fadeOut(withDuration: 0.4)
            let remove = SKAction.removeFromParent()
            let retry = SKAction.run {
                self.riddleIndex = 0
                self.correctAnswers = 0
                self.presentRiddle()
            }

            let sequence = SKAction.sequence([appear, wait, disappear, remove, retry])
            warningBox.run(sequence)


            return
        }

        // ✅ Player got at least one correct
        let rewardHealing = (correctAnswers == 3)

        if let view = self.view {
            let nextScene = CastleInteriorScene(
                size: view.bounds.size,
                hasHealingCard: rewardHealing,
                showCards: showCards
            )
            nextScene.scaleMode = .resizeFill
            view.presentScene(nextScene, transition: .doorway(withDuration: 1.0))
        }

        backgroundMusic?.run(SKAction.stop())
    }
    
    override func update(_ currentTime: TimeInterval) {
        if inRiddle { return }
        if let target = targetLocation {
            let dx = target.x - player.position.x
            let dy = target.y - player.position.y
            let distance = sqrt(dx * dx + dy * dy)

            if distance > 10 {
                let direction = CGVector(dx: dx / distance, dy: dy / distance)
                player.physicsBody?.velocity = CGVector(dx: direction.dx * walkSpeed, dy: direction.dy * walkSpeed)
                player.setWalkAnimation()
            } else {
                player.physicsBody?.velocity = .zero
                player.stopWalking()
                targetLocation = nil
                targetMarker?.isHidden = true
            }
        } else {
            let speed = hypot(player.physicsBody?.velocity.dx ?? 0, player.physicsBody?.velocity.dy ?? 0)
            if speed < 10 {
                player.stopWalking()
                player.physicsBody?.velocity = .zero
            }
        }

        let lerpFactor: CGFloat = 0.1
        let target = CGPoint(x: player.position.x, y: player.position.y + 150)
        let halfWidth = (size.width * cameraNode.xScale) / 2
        let halfHeight = (size.height * cameraNode.yScale) / 2
        let minX = halfWidth
        let maxX = backgroundNode?.frame.maxX ?? size.width - halfWidth
        let minY = halfHeight
        let maxY = backgroundNode?.frame.maxY ?? size.height - halfHeight

        let clampedX = clamp(target.x, minX, maxX - halfWidth)
        let clampedY = clamp(target.y, minY, maxY - halfHeight)

        if targetLocation != nil {
            cameraNode.position.x += (clampedX - cameraNode.position.x) * lerpFactor
            cameraNode.position.y += (clampedY - cameraNode.position.y) * lerpFactor
        } else {
            cameraNode.position = CGPoint(x: clampedX, y: clampedY)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodesAtPoint = nodes(at: location)

        if inRiddle {
            for node in nodesAtPoint {
                if node.name == "Choice_Correct" {
                    run(SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false)) // ✅ correct
                    correctAnswers += 1
                    riddleIndex += 1
                    presentRiddle()
                    return
                } else if node.name == "Choice_Wrong" {
                    run(SKAction.playSoundFileNamed("buzz.wav", waitForCompletion: false)) // ❌ wrong
                    riddleIndex += 1
                    presentRiddle()
                    return
                }
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        if inRiddle { return }

        let locationInView = touch.location(in: view!)
        let scenePoint = self.convert(locationInView, from: self.view!)
        print("📍Touch at scene location: \(scenePoint)")


        let minX = backgroundNode?.frame.minX ?? 0
        let maxX = backgroundNode?.frame.maxX ?? size.width
        let minY = backgroundNode?.frame.minY ?? 0
        let maxY = backgroundNode?.frame.maxY ?? size.height

        let clampedX = max(minX + 10, min(scenePoint.x, maxX - 10))
        let clampedY = max(minY + 10, min(scenePoint.y, maxY - 10))
        let finalTarget = CGPoint(x: clampedX, y: clampedY)

        targetLocation = finalTarget
        targetMarker?.position = finalTarget
        targetMarker?.isHidden = false
        player.setWalkAnimation()
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }

        let nameA = nodeA.name ?? ""
        let nameB = nodeB.name ?? ""

        let isPlayer = nameA == "Player" || nameB == "Player"
        let isWolf = nameA == "WolfNPC" || nameB == "WolfNPC"
        let isZone = nameA == "RiddleZone" || nameB == "RiddleZone"

        if isPlayer && (isWolf || isZone) && !inRiddle {
            presentRiddle()
        }
    }

    private func clamp(_ value: CGFloat, _ min: CGFloat, _ max: CGFloat) -> CGFloat {
        return Swift.max(min, Swift.min(value, max))
    }
}

