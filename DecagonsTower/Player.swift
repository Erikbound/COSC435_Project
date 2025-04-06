//
//  Player.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 4/5/25.
//
import SpriteKit
import GameplayKit

// MARK: - Player
class Player: SKSpriteNode {
    required override init(texture: SKTexture?, color: UIColor, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // Loads Idle frames when not walking
    static func loadIdleFrames() -> [SKTexture] {
        var frames: [SKTexture] = []
        let spriteSheet = SKTexture(imageNamed: "Soldier-Idle")
        let frameCount = 6;
        let frameWidth = 1.0 / CGFloat(frameCount)
        let frameHeight = 1.0

        for i in 0..<frameCount {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: frameHeight)
            let texture = SKTexture(rect: rect, in: spriteSheet)
            frames.append(texture)
        }
        
        return frames
    }

    // Sets idle animation
    func setIdleAnimation() {
        let idleFrames = Player.loadIdleFrames()
        
        // Ensure we have frames before starting animation
        guard !idleFrames.isEmpty else { return }
        
        let idleAnimation = SKAction.animate(with: idleFrames, timePerFrame: 0.1)
        // idle Key used to play idle animation
        self.run(SKAction.repeatForever(idleAnimation), withKey: "idle")
    }
    
    // Set walk animation
    func setWalkAnimation() {
        // Replaces walk key with idle when player character moving
        if action(forKey: "walk") != nil { return }
        self.removeAction(forKey: "idle")
        
        let walkFrames = Player.loadWalkFrames()
        guard !walkFrames.isEmpty else { return }
        
        let walkAnimation = SKAction.animate(with: walkFrames, timePerFrame: 0.1)
        self.run(SKAction.repeatForever(walkAnimation), withKey: "walk")
    }
    
    // Loads walk frames
    static func loadWalkFrames() -> [SKTexture] {
        var frames: [SKTexture] = []
        let spriteSheet = SKTexture(imageNamed: "Soldier-Walk")
        let frameCount = 8;
        let frameWidth = 1.0 / CGFloat(frameCount)
        let frameHeight = 1.0
        
        for i in 0..<frameCount {
            let rect = CGRect(x: CGFloat(i) * frameWidth, y: 0, width: frameWidth, height: frameHeight)
            let texture = SKTexture(rect: rect, in: spriteSheet)
            frames.append(texture)
        }
        
        return frames
    }
    
    // Plays Idle animation when no longer walking
    func stopWalking() {
        if action(forKey: "walk") != nil {
            self.removeAction(forKey: "walk")
            self.setIdleAnimation()
        }
    }
}
