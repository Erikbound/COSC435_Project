import SpriteKit
import GameplayKit

enum PhysicsCategory {
    case player
    case tree
    case water
    
    var value: UInt32 {
        switch self {
        case .player: 0x1 << 0
        case .tree: 0x1 << 1
        case .water: 0x1 << 2
        }
    }
}

class GameScene: SKScene {
    var player: Player! // Creates player character sprite
    var tileMap: SKTileMapNode! // Creates a tiled map
    
    // Called when the scene is first presented to the view
    override func didMove(to view: SKView) {
        setupScene()
        setupTileMap()
    }
    
    
    
    // Sets map as a big green tile, player character loaded from assets, and places player on the map
    func setupScene() {
        backgroundColor = .green

        // Load the first frame from the sprite sheet
        let idleFrames = Player.loadIdleFrames()
        let firstFrame = idleFrames.first ?? SKTexture(imageNamed: "Soldier-Idle")
        
        // Initialize player with first frame
        player = Player(texture: SKTexture(imageNamed: "soldier-test"), color: .clear, size: CGSize(width: 23, height: 27))
        
//        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        player.position = .init(x: 0, y: 0)
        player.physicsBody = makePlayerPhysicsBody(size: player.frame.size)
        
        
        addChild(player)
        player.setIdleAnimation() // Start idle animation
        
        
        if let tree1 = childNode(withName: "tree1") {
            tree1.physicsBody = makeTreePhysicsBody(size: tree1.frame.size)
            
        } else {
            print("TREE 1 not found")
        }

        
        physicsWorld.contactDelegate = self
        
    }
    
    private func makeTreePhysicsBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = false
        body.affectedByGravity = false
        body.categoryBitMask = PhysicsCategory.tree.value
        body.collisionBitMask = PhysicsCategory.player.value
    
        return body
    }
    
    private func makePlayerPhysicsBody(size: CGSize) -> SKPhysicsBody {
        let body = SKPhysicsBody(rectangleOf: size)
        body.isDynamic = true
        body.affectedByGravity = false
        body.allowsRotation = false
        body.categoryBitMask = PhysicsCategory.player.value
        body.collisionBitMask = PhysicsCategory.tree.value
        body.contactTestBitMask = PhysicsCategory.tree.value
        return body
    }
    
    // Setup for tiled map
    func setupTileMap() {
        tileMap = childNode(withName: "TileMap") as? SKTileMapNode
    }
    
    // Player movements are determined by touching a specific tile on screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePlayer(to: location)
    }
    
    // Moves players to that tile and plays animation
    func movePlayer(to position: CGPoint) {
        
        let currentPosition = player.position
        
        let dx = position.x - currentPosition.x
        let dy = position.y - currentPosition.y
        let alpha: CGFloat = 0.001
        let maxDelta: CGFloat = 300
        
        var finalDX = dx
        if abs(dx) > maxDelta {
            finalDX = maxDelta * (dx > 0 ? 1 : -1)
        }
        var finalDY = dy
        if abs(dy) > maxDelta {
            finalDY = maxDelta * (dy > 0 ? 1 : -1)
        }
        
        print(dx * alpha)
        player.physicsBody?.applyImpulse(.init(dx: finalDX, dy: finalDY))
    }
}

// Player class with idle animation
class Player: SKSpriteNode {
    
    // Initialize player with a specific texture
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Load idle frames from sprite sheet
    static func loadIdleFrames() -> [SKTexture] {
        var frames: [SKTexture] = []
        
        let spriteSheet = SKTexture(imageNamed: "Soldier-Idle")
        let frameCount = 6  // Number of frames in the sprite sheet
        let frameWidth = 1.0 / CGFloat(frameCount) // Normalized width per frame
        let frameHeight = 1.0  // Since it's a single row
        
        // Used to animate player character
        for i in 0..<frameCount {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: frameHeight)
            let texture = SKTexture(rect: rect, in: spriteSheet)
            frames.append(texture)
        }
        
        return frames
    }

    // Set idle animation for the player
    func setIdleAnimation() {
        let idleFrames = Player.loadIdleFrames()
        
        // Ensure we have frames before starting animation
        guard !idleFrames.isEmpty else { return }
        
        let idleAnimation = SKAction.animate(with: idleFrames, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(idleAnimation))
    }
}

extension GameScene: SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        contact.bodyA.velocity = .init(dx: 0, dy: 0)
        contact.bodyB.velocity = .init(dx: 0, dy: 0)
    }
}
