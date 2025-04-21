//
//  CardData.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/31/25.
//

import Foundation
import UIKit

struct CardData: Hashable{
    
    let name: String
    let energyCost: Int //Number of energy needed to use card
    let atkPower: Int //Base amount of damage on card’s attack
    let healPower: Int //Amount of HP card can heal
    let stealPower: Int //Amount of Energy card can steal
    
    let atkBoost: Int //If card has atkBoost, then the next attack does more damage
    let defBoost: Int //If card has defBoost, then next damage taken does less damage
    
}

class CardDatabase{
    static let allCards = CardDatabase()
    
    let cards: [String: CardData] = [
        "Slime": CardData(name: "Slime", energyCost: 1, atkPower: 10, healPower: 0, stealPower: 0, atkBoost: 0, defBoost: 0),
        "Knight": CardData(name: "Knight", energyCost: 2, atkPower: 20, healPower: 0, stealPower: 0, atkBoost: 0, defBoost: 0),
        "Mage": CardData(name: "Mage", energyCost: 2, atkPower: 0, healPower: 20, stealPower: 0, atkBoost: 0, defBoost: 0),
        "Theif": CardData(name: "Theif", energyCost: 1, atkPower: 10, healPower: 0, stealPower: 3, atkBoost: 0, defBoost: 0),
        "Castle Guard": CardData(name: "Castle Guard", energyCost: 2, atkPower: 0, healPower: 0, stealPower: 0, atkBoost: 0, defBoost: 20),
        "Wolf": CardData(name: "Wolf", energyCost: 4, atkPower: 20, healPower: 0, stealPower: 0, atkBoost: 20, defBoost: 0),
    ]
    
    func getCard(name: String) -> CardData?{
        return cards[name]
    }
    
}

