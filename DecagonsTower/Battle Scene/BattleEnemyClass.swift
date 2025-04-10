//
//  BattleEnemyClass.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/30/25.
//
import Foundation

class BattleEnemyClass {
    var maxHP: Int = 100
    var currentHP: Int
    var maxEnergy: Int = 10
    var currentEnergy: Int
    var currentAtkBoost : Int = 0
    var currentDefBoost : Int = 0
    
    var maxDeckSize: Int
    var deckSize: Int
    
    
    init() {
        self.currentHP = self.maxHP
        self.currentEnergy = self.maxEnergy
        self.maxDeckSize = 5 //This changes on level up
        self.deckSize = 5
    }
    
}
