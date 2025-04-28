//
//  WolfNPC.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 4/25/25.
//
import SpriteKit

// Handles Wolf NPC Animation
class WolfNPC: SKSpriteNode {
    private var idleFrames: [SKTexture] = []
    let portraitTexture = SKTexture(imageNamed: "wolfPortrait")

    init() {
        let texture = SKTexture(imageNamed: "wolf_gray_full")
        let firstFrame = SKTexture(rect: CGRect(x: 1/12, y: 6/8, width: 1/11, height: 2/11), in: texture)
        super.init(texture: firstFrame, color: .clear, size: firstFrame.size())
        prepareIdleAnimation(spriteSheet: texture)
        startIdleAnimation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Plays first six frames for animation
    private func prepareIdleAnimation(spriteSheet: SKTexture) {
        for i in 0..<6 {
            let rect = CGRect(
                x: CGFloat(i) / 12,
                y: 6/8,
                width: 1/12,
                height: 1/8
            )
            let frame = SKTexture(rect: rect, in: spriteSheet)
            idleFrames.append(frame)
        }
    }
    
    private func startIdleAnimation() {
        let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.15)
        let repeatIdle = SKAction.repeatForever(idleAction)
        run(repeatIdle)
    }
}
