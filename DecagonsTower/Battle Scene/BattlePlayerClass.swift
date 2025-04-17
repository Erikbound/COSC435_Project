//
//  BattlePlayerClass.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/30/25.
//

import Foundation
import UIKit

class BattlePlayerClass{
    var maxHP: Int = 400
    var currentHP: Int
    var maxEnergy: Int = 10
    var currentEnergy: Int
    var currentAtkBoost : Int = 0
    var currentDefBoost : Int = 0
    
    var maxDeckSize: Int
    var deck: [CardData] = []
    
    let maxHandSize: Int = 3
    var hand: [CardData] = []
    
    let maxDiscardSize: Int = 10
    var discardPile: [CardData] = []
    
    
    init() {
        self.currentHP = self.maxHP
        self.currentEnergy = 5
        self.maxDeckSize = 5 //This changes on level up
        
        for _ in 0..<self.maxDeckSize{
            let randCard = "Slime"
            AddCardtoDeck(name: randCard)
        }
    }
    
    func AddCardtoDeck(name: String){
        let card = CardDatabase.allCards.getCard(name: name)!
        deck.append(card)
    }
    
    func DrawCardFromDeck(){
            //If hand isn't full and deck isn't empty
        if hand.count < maxHandSize && deck.count > 0{
                //Draw a random card from deck and add to hand
            let randomCardIndex: Int = Int.random(in: 0..<deck.count)
            
            hand.append(deck.remove(at: randomCardIndex))
        }
    }
    
    func AddEnergy(amount: Int){
        if currentEnergy + amount <= maxEnergy{
            currentEnergy += amount
        } else {
            currentEnergy = maxEnergy
        }
    }
    
}
