import SpriteKit
import GameplayKit

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
        player = Player(texture: firstFrame, color: .clear, size: CGSize(width: 264, height: 264))
        player.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        
        addChild(player)
        player.setIdleAnimation() // Start idle animation
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
        let moveAction = SKAction.move(to: position, duration: 0.5)
        player.run(moveAction)
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
