//
//  KnightNPC.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 5/3/25.
//

import SpriteKit

// Mainly used for Knights Idle Animation
class KnightNPC: SKSpriteNode {
    var idleFrames: [SKTexture] = []

    init() {
        let texture = SKTexture(imageNamed: "knightIdle.png")
        let textureWidth = texture.size().width / 7
        let textureHeight = texture.size().height
        
        for i in 0..<7 {
            let frameRect = CGRect(x: CGFloat(i) / 7, y: 0, width: 1 / 7, height: 1)
            let frame = SKTexture(rect: frameRect, in: texture)
            idleFrames.append(frame)
        }

        super.init(texture: idleFrames[0], color: .clear, size: idleFrames[0].size())

        startIdleAnimation()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func startIdleAnimation() {
        let idleAction = SKAction.animate(with: idleFrames, timePerFrame: 0.1, resize: false, restore: true)
        run(SKAction.repeatForever(idleAction))
    }
}
