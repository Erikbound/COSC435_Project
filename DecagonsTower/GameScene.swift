import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let interactionZone: UInt32 = 0x1 << 2
    static let wolf: UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    var wolfNPC: SKSpriteNode!
    var riddleZone: SKNode!
    var riddleUI: SKNode?
    var inRiddle = false
    var riddleIndex = 0
    var correctAnswers = 0

    let riddles: [(question: String, correct: String, wrong: String)] = [
        ("What has to be broken before you can use it?", "An egg", "A clock"),
        ("What goes up but never comes down?", "Your age", "A balloon"),
        ("I’m tall when I’m young, and I’m short when I’m old. What am I?", "A candle", "A pencil")
    ]

    override func didMove(to view: SKView) {
        backgroundColor = .green
        physicsWorld.contactDelegate = self

        addMapBackground()
        setupPlayer()
        setupWolf()
        setupRiddleZone()
    }

    func addMapBackground() {
        let map = SKSpriteNode(imageNamed: "map") // Make sure "map" is added to Assets
        map.position = CGPoint(x: size.width / 2, y: size.height / 2)
        map.zPosition = -10
        map.size = size
        addChild(map)
    }

    func setupPlayer() {
        let firstFrame = Player.loadIdleFrames().first ?? SKTexture()
        player = Player(texture: firstFrame, color: .clear, size: CGSize(width: 23, height: 27))
        player.position = CGPoint(x: size.width / 2, y: 60)
        player.zPosition = 10
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.isDynamic = true
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.allowsRotation = false
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.wolf | PhysicsCategory.interactionZone
        addChild(player)
        player.setIdleAnimation()
    }

    func setupWolf() {
        wolfNPC = SKSpriteNode(imageNamed: "Wolf") // Make sure "Wolf" is added to Assets
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
        let wiggleLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.5)
        let wiggleRight = SKAction.moveBy(x: 5, y: 0, duration: 0.5)
        let wiggle = SKAction.sequence([wiggleLeft, wiggleRight])
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
        guard let touch = touches.first else { return }
        if inRiddle { return }

        let target = touch.location(in: self)
        let distance = hypot(player.position.x - target.x, player.position.y - target.y)
        let speed: CGFloat = 100.0
        let duration = TimeInterval(distance / speed)

        if target.x < player.position.x {
            player.xScale = -1
        } else {
            player.xScale = 1
        }

        let moveAction = SKAction.move(to: target, duration: duration)
        player.run(moveAction)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let node = atPoint(location)

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
            let nextScene = CastleInteriorScene(size: view.bounds.size, hasHealingCard: rewardHealing)
            nextScene.scaleMode = .resizeFill
            view.presentScene(nextScene, transition: .doorway(withDuration: 1.0))
        }
    }
}

// MARK: - Player
class Player: SKSpriteNode {
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    static func loadIdleFrames() -> [SKTexture] {
        var frames: [SKTexture] = []
        let spriteSheet = SKTexture(imageNamed: "Soldier-Idle") // Sprite sheet with 6 frames side-by-side
        spriteSheet.filteringMode = .nearest

        let count = 6
        let frameWidth = 1.0 / CGFloat(count)

        for i in 0..<count {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: 1)
            let texture = SKTexture(rect: rect, in: spriteSheet)
            texture.filteringMode = .nearest
            frames.append(texture)
        }

        return frames
    }

    func setIdleAnimation() {
        let frames = Player.loadIdleFrames()
        let animate = SKAction.animate(with: frames, timePerFrame: 0.1)
        run(SKAction.repeatForever(animate), withKey: "Idle")
    }
}

// MARK: - CastleInteriorScene
class CastleInteriorScene: SKScene {
    var hasHealingCard: Bool = false
    var inventory: [String: Bool] = [:]

    init(size: CGSize, hasHealingCard: Bool) {
        self.hasHealingCard = hasHealingCard
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func didMove(to view: SKView) {
        backgroundColor = .darkGray

        let label = SKLabelNode(text: "🏰 Inside the Castle")
        label.fontSize = 28
        label.fontColor = .white
        label.position = CGPoint(x: size.width / 2, y: size.height - 100)
        addChild(label)

        inventory = [
            "Hit": true,
            "Repel": true,
            "Healing": hasHealingCard,
            "Laser": true
        ]

        setupInventoryUI()
    }

    func setupInventoryUI() {
        let cardNames = ["Hit", "Repel", "Healing", "Laser"]
        let spacing: CGFloat = 80
        let startX = size.width / 2 - spacing * 1.5

        for (i, name) in cardNames.enumerated() {
            let unlocked = inventory[name] ?? false
            let color = unlocked ? SKColor.white : SKColor.gray
            let card = SKSpriteNode(color: color, size: CGSize(width: 60, height: 80))
            card.name = "Card_\(name)"
            card.position = CGPoint(x: startX + CGFloat(i) * spacing, y: 100)

            let label = SKLabelNode(text: name)
            label.fontSize = 12
            label.fontColor = .black
            label.verticalAlignmentMode = .center
            card.addChild(label)

            addChild(card)
        }
    }
}
