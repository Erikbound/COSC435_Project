//
//  PhysicsCategory.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/18/25.
//

struct PhysicsCategory {
    static let player: UInt32 = 0x1 << 0
    static let obstacle: UInt32 = 0x1 << 1
    static let interactionZone: UInt32 = 0x1 << 2
    static let wolf: UInt32 = 0x1 << 3
    static let castle: UInt32 = 0x1 << 4
    static let enemyKnight: UInt32 = 0x1 << 5
}
