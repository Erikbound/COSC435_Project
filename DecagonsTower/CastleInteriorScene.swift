//
//  Database.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/22/25.
import SpriteKit
import GameplayKit
import AVFAudio

class CastleInteriorScene: SKScene, SKPhysicsContactDelegate {
    var player: Player!
    var enemyNPC: KnightNPC!
    var battleZone: SKNode!
    var inBattleZone = false
    var castleAudioEngine: AVAudioEngine!
    var castleMusicPlayer: AVAudioPlayerNode!
    var castleMusicFile: AVAudioFile!

    let showCards: (Bool) -> Void
    let completion: (BattleResult) -> Void
    
    private var cameraNode = SKCameraNode()
    private var movementDirection: CGVector?
    
    var hasHealingCard: Bool = false

    init(size: CGSize, hasHealingCard: Bool, showCards: @escaping (Bool) -> Void, completion: @escaping (BattleResult) -> Void) {
        self.hasHealingCard = hasHealingCard
        self.showCards = showCards
        self.completion = completion
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
        setUpBoundary()
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
//
    private func setUpBoundary() {
        let width: CGFloat = 350 + player.size.width
        let height: CGFloat = 735 + player.size.width
        let x: CGFloat = size.width / 2
        let y: CGFloat = size.height / 2
        let size = CGSize(width: width, height: height)

        // Main Boundary (edge loop with visible color)
        let boundary = SKShapeNode(rectOf: size)
        boundary.position = CGPoint(x: x, y: y)

        // Red outline and transparent fill
        boundary.strokeColor = .clear
        boundary.lineWidth = 5
        boundary.fillColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)

        // Physics → edge loop
        boundary.physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        boundary.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        boundary.physicsBody?.contactTestBitMask = PhysicsCategory.player
        boundary.physicsBody?.collisionBitMask = PhysicsCategory.player // block player at edges
        boundary.name = "Boundary"
        addChild(boundary)

        // Extra Top Blocker (visible)
        let topBlockerWidth: CGFloat = width
        let topBlockerHeight: CGFloat = 10 // thin wall

        let topBlocker = SKShapeNode(rectOf: CGSize(width: topBlockerWidth, height: topBlockerHeight))
        topBlocker.position = CGPoint(x: x, y: y + height / 2 - 154) // LOWERED by 150 points
        topBlocker.strokeColor = .clear
        topBlocker.lineWidth = 5
        topBlocker.fillColor = SKColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0) // light blue

        topBlocker.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: topBlockerWidth, height: topBlockerHeight))
        topBlocker.physicsBody?.isDynamic = false
        topBlocker.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        topBlocker.physicsBody?.contactTestBitMask = PhysicsCategory.player
        topBlocker.physicsBody?.collisionBitMask = PhysicsCategory.player

        addChild(topBlocker)
    }
    func setupPlayer(contactTestBitMask: UInt32) {
        let firstFrame = Player.loadIdleFrames().first ?? SKTexture()
        player = Player(texture: firstFrame, color: .clear, size: CGSize(width: 125, height: 125))
        player.position = CGPoint(x: size.width / 2, y: (size.height / 2) - 350)
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
        let knight = KnightNPC()
        knight.size = CGSize(width: 150, height: 150)
        knight.position = CGPoint(x: size.width / 2, y: 410)
        knight.zPosition = 10
        knight.physicsBody = SKPhysicsBody(rectangleOf: knight.size)
        knight.physicsBody?.isDynamic = false
        knight.physicsBody?.categoryBitMask = PhysicsCategory.enemyKnight
        knight.physicsBody?.contactTestBitMask = PhysicsCategory.player
        knight.name = "Enemy Knight"
        addChild(knight)
        enemyNPC = knight
    }
    
    func presentKnightDialog() {
        // Create dialog container node
        let knightDialogUI = SKNode()
        knightDialogUI.name = "Knight Dialogue"
        knightDialogUI.zPosition = 1000

        // Main Dialog Box
        let boxWidth: CGFloat = 360
        let boxHeight: CGFloat = 300
        let box = SKShapeNode(rectOf: CGSize(width: boxWidth, height: boxHeight), cornerRadius: 18)
        box.fillColor = .black
        box.strokeColor = .white
        box.lineWidth = 3
        box.position = CGPoint(x: 0, y: -(size.height/2) + boxHeight/2 + 20)
        knightDialogUI.addChild(box)

        // Knight Portrait
        let portrait = SKSpriteNode(texture: SKTexture(imageNamed: "knightPortrait"))
        portrait.size = CGSize(width: 60, height: 60)
        portrait.position = CGPoint(x: box.position.x - boxWidth/2 + 50, y: box.position.y + boxHeight/2 - 50)
        portrait.zPosition = box.zPosition + 1
        knightDialogUI.addChild(portrait)

        // Knight Name Label
        let nameLabel = SKLabelNode(text: "Knight")
        nameLabel.fontName = "AvenirNext-Bold"
        nameLabel.fontSize = 18
        nameLabel.fontColor = .white
        nameLabel.horizontalAlignmentMode = .left
        nameLabel.verticalAlignmentMode = .center
        nameLabel.position = CGPoint(x: portrait.position.x + 40, y: portrait.position.y)
        nameLabel.zPosition = box.zPosition + 1
        knightDialogUI.addChild(nameLabel)

        // Knight Message
        let message = SKLabelNode(text: "Never should've come here.")
        message.fontName = "AvenirNext-Regular"
        message.fontSize = 18
        message.fontColor = .white
        message.horizontalAlignmentMode = .left
        message.verticalAlignmentMode = .top
        message.preferredMaxLayoutWidth = boxWidth - 40
        message.numberOfLines = 0
        message.position = CGPoint(x: box.position.x - boxWidth/2 + 20, y: nameLabel.position.y - 60)
        message.zPosition = box.zPosition + 1
        knightDialogUI.addChild(message)

        // Choice Container Box
        let choiceBoxWidth: CGFloat = boxWidth - 40
        let choiceBoxHeight: CGFloat = 80
        let choiceBox = SKShapeNode(rectOf: CGSize(width: choiceBoxWidth, height: choiceBoxHeight), cornerRadius: 12)
        choiceBox.fillColor = .darkGray
        choiceBox.strokeColor = .white
        choiceBox.lineWidth = 2
        choiceBox.position = CGPoint(x: box.position.x, y: box.position.y - boxHeight/2 + choiceBoxHeight/2 + 20)
        choiceBox.zPosition = box.zPosition + 1
        knightDialogUI.addChild(choiceBox)

        // Fight Button
        let fightButton = SKLabelNode(text: "Fight")
        fightButton.name = "FightButton"
        fightButton.fontName = "AvenirNext-Bold"
        fightButton.fontSize = 18
        fightButton.fontColor = .white
        fightButton.horizontalAlignmentMode = .center
        fightButton.verticalAlignmentMode = .center
        fightButton.position = CGPoint(x: -60, y: 0)
        fightButton.zPosition = choiceBox.zPosition + 1
        choiceBox.addChild(fightButton)

        // Run Away Button
        let runButton = SKLabelNode(text: "Run Away")
        runButton.name = "RunButton"
        runButton.fontName = "AvenirNext-Bold"
        runButton.fontSize = 18
        runButton.fontColor = .white
        runButton.horizontalAlignmentMode = .center
        runButton.verticalAlignmentMode = .center
        runButton.position = CGPoint(x: 60, y: 0)
        runButton.zPosition = choiceBox.zPosition + 1
        choiceBox.addChild(runButton)

        // Add dialog UI to camera or scene
        cameraNode.addChild(knightDialogUI)
        
        animateText("Never should've come here.", on: message, characterDelay: 0.04) {
            fightButton.isHidden = false
            runButton.isHidden = false
        }
    }
    
    func removeDialog() {
        childNode(withName: "DialogBox")?.removeFromParent()
        cameraNode.childNode(withName: "Knight Dialogue")!.removeFromParent()
    }

    func presentBattleScreen() {
        if let view = self.view, let viewController = view.window?.rootViewController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as? BattleViewController {
                battleVC.modalPresentationStyle = .fullScreen
                battleVC.completion = { [weak self] result in self?.completion(result) }
                viewController.present(battleVC, animated: true, completion: nil)
            }
        }
    }

    func sendPlayerBackToMap() {
        player.run(.move(by: .init(dx: 0, dy: -100), duration: 0.5))
    }
    
    // Animate the dialog Text
    func animateText(_ text: String, on label: SKLabelNode, characterDelay: TimeInterval, completion: @escaping () -> Void) {
        label.text = ""
        let characters = Array(text)
        var charIndex = 0

        let wait = SKAction.wait(forDuration: characterDelay)
        let addCharacter = SKAction.run { [weak label] in
            guard charIndex < characters.count else { return }
            label?.text?.append(characters[charIndex])
            charIndex += 1
        }
        
        let sequence = SKAction.sequence([wait, addCharacter])
        let repeatAction = SKAction.repeat(sequence, count: characters.count)
        
        label.run(repeatAction, completion: completion)
    }
    
    func setUpBattleZone() {
        battleZone = SKSpriteNode(color: .clear, size: .init(width: 200, height: 30))
        battleZone.position = CGPoint(x: size.width / 2, y: 310)
        battleZone.physicsBody = SKPhysicsBody(circleOfRadius: 30)
        battleZone.physicsBody?.isDynamic = false
        battleZone.physicsBody?.categoryBitMask = PhysicsCategory.interactionZone
        battleZone.physicsBody?.contactTestBitMask = PhysicsCategory.player
        battleZone.physicsBody?.collisionBitMask = 0
        battleZone.zPosition = -1
        battleZone.name = "Battle Zone"
        addChild(battleZone)
        
        let label = SKLabelNode(text: "Enter the battle zone from the front")
        label.position = CGPoint(x: size.width / 2, y: 220)
        label.fontSize = 14.0
        label.fontName = "HelveticaNeue-Bold"
        label.numberOfLines = 2
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
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

        if node.name == "FightButton" {
            removeDialog()
            presentBattleScreen()
        } else if node.name == "RunButton" {
            let location = CGPoint(x: player.position.x, y: player.position.y - 100)
            movePlayerToward(location)
        } else {
            movePlayerToward(location)
        }

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
        
        
//        guard contact.bodyA.categoryBitMask == PhysicsCategory.interactionZone ||
//                contact.bodyB.categoryBitMask == PhysicsCategory.interactionZone
//        else { return }
//
//        if let view = self.view, let viewController = view.window?.rootViewController {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                if let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as? BattleViewController {
//                    battleVC.modalPresentationStyle = .fullScreen
//                    battleVC.completion = { [weak self] result in self?.completion(result) }
//                    viewController.present(battleVC, animated: true, completion: nil)
//                }
//            }
        
        guard contact.bodyA.categoryBitMask == PhysicsCategory.interactionZone ||
              contact.bodyB.categoryBitMask == PhysicsCategory.interactionZone
        else { return }

        if !inBattleZone {
            inBattleZone = true
            presentKnightDialog()
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
