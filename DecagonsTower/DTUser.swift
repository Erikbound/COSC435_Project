//
//  DTUser.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//

import Foundation

class DTUser: Codable, Identifiable {
    let id: String
    let email: String
    let username: String
    var enemiesDefeated: Int
    var cardsCollected: Int
    
    init(
        id: String,
        email: String,
        username: String,
        enemiesDefeated: Int = 0,
        cardsCollected: Int = 0
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.enemiesDefeated = enemiesDefeated
        self.cardsCollected = cardsCollected
    }
}
