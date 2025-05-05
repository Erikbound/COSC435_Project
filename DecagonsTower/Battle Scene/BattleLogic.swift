//
//  BattleLogic.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/27/25.
//

import Foundation
import UIKit
    
extension BattleViewController {
    
    func CheckBattleState(state: battleState){
        switch state {
            case battleState.playerTurn:
                ExecutePlayerTurn()
            case battleState.enemyTurn:
                ExecuteEnemyTurn()
            case battleState.playerWin:
                break
            case battleState.playerLose: break
        }
        
    }

    func ExecutePlayerTurn(){
            //If you didn't play a card last turn, don't draw a card
        battlePlayer.DrawCardFromDeck()
        battlePlayer.AddEnergy(amount: 1)
        
        EndTurnButtonOutlet.isEnabled = true
        EndTurnButtonOutlet.alpha = 1
        
        Textbox.text = "It's your turn.\nPlay a card or end your turn."
        UpdateUI()
    }
    
    func PlayerUseCard(card: CardData, deckIndex: Int){
            //Spend Energy Cost
        battlePlayer.currentEnergy -= card.energyCost
        
            //Attack/Defend
        if card.atkPower > 0 {
            var damage: Int = card.atkPower + battlePlayer.currentAtkBoost - battleEnemy.currentDefBoost
            
            if damage > 0 {
                battleEnemy.currentHP -= damage
                if battleEnemy.currentHP <= 0 {
                    battleEnemy.currentHP = 0
                }
            } else {
                damage = 0
            }
            
                //Reset last turn's boosts
            battlePlayer.currentAtkBoost = 0
            battleEnemy.currentDefBoost = 0
        }
        
            //Apply AtkBoost and DefBoost for next turn
        if card.atkBoost > 0 {
            battlePlayer.currentAtkBoost += card.atkBoost
        }
        if card.defBoost > 0 {
            battlePlayer.currentDefBoost += card.defBoost
        }
        
            //Heal
        if card.healPower > 0 && battlePlayer.currentHP < battlePlayer.maxHP{
            battlePlayer.currentHP += card.healPower
            if battlePlayer.currentHP > battlePlayer.maxHP {
                battlePlayer.currentHP = battlePlayer.maxHP
            }
        }
        
            //Steal Energy
        if card.stealPower > 0 {
            battleEnemy.currentEnergy -= card.stealPower
            if battleEnemy.currentEnergy < 0 {
                battleEnemy.currentEnergy = 0
            }
            
            battlePlayer.currentEnergy += card.stealPower
            if battlePlayer.currentEnergy > battlePlayer.maxEnergy {
                battlePlayer.currentEnergy = battlePlayer.maxEnergy
            }
        }
        
        //Put card in discard pile
        battlePlayer.AddCardtoDiscardPile(card: card, deckIndex: deckIndex)
        
    }
    
    func ExecuteEnemyTurn(){
        Textbox.text = "The enemy is making their move..."
        
        battleEnemy.DrawCardFromDeck()
        battleEnemy.AddEnergy(amount: 1)
        UpdateUI()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [self] in
            // Code here runs after 2 seconds
            
            UsedCard.image = UIImage(named: battleEnemy.hand[0].name)
            
            Textbox.text = "Enemy used\n\(battleEnemy.hand[0].name)!"
            
            if EnemyUseCard(card: battleEnemy.hand[0], deckIndex: 0){
                
                // Animate Card
                UsedCard.isHidden = false
                UIView.animate(withDuration: 0.3,
                               delay: 0,
                               usingSpringWithDamping: 0.6,
                               initialSpringVelocity: 1.0,
                               options: [],
                               animations: { [self] in
                    UsedCard.frame.origin = UsedCardEnemyEndingPoint
                }){ _ in
                    // Wait 1.5 second after animation finishes
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
                        UsedCard.isHidden = true
                        UsedCard.frame.origin = UsedCardPlayerStartingPoint
                        
                        UpdateUI()
                        //Change Turns
                        if battlePlayer.currentHP > 0 && battleEnemy.hand.count > 0{
                            currentBattleState = battleState.playerTurn
                            CheckBattleState(state: battleState.playerTurn)
                        } else {
                            if battlePlayer.currentHP == 0{
                                Textbox.text = "You have been defeated!"
                                CheckBattleState(state: battleState.playerLose)
                                UpdateUI()
                                completion?(.init(cardsWon: 0, didWin: false))
                            } else if battleEnemy.hand.count == 0{
                                Textbox.text = "The enemy is out of cards!\nYou win!"
                                CheckBattleState(state: battleState.playerWin)
                                UpdateUI()
                                completion?(.init(cardsWon: Int.random(in: 2...3), didWin: true))
                            }
                        }
                    }
                }
            }
            else{
                Textbox.text = "The enemy is out of energy and\ncouldn't attack!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [self] in
                    currentBattleState = battleState.playerTurn
                    CheckBattleState(state: battleState.playerTurn)
                }
            }
                    
        }
    }
    
    
    func EnemyUseCard(card: CardData, deckIndex: Int) -> Bool{
        
                //Spend Energy Cost
        if battleEnemy.currentEnergy >= card.energyCost {
            battleEnemy.currentEnergy -= card.energyCost
        } else{
            return false
        }
            
            
                //Attack/Defend
            if card.atkPower > 0 {
                var damage: Int = card.atkPower + battleEnemy.currentAtkBoost - battlePlayer.currentDefBoost
                
                if damage > 0 {
                    battlePlayer.currentHP -= damage
                    if battlePlayer.currentHP <= 0 {
                        battlePlayer.currentHP = 0
                    }
                } else {
                    damage = 0
                }
                
                    //Reset last turn's boosts
                battleEnemy.currentAtkBoost = 0
                battlePlayer.currentDefBoost = 0
            }
            
                //Apply AtkBoost and DefBoost for next turn
            if card.atkBoost > 0 {
                battleEnemy.currentAtkBoost += card.atkBoost
            }
            if card.defBoost > 0 {
                battleEnemy.currentDefBoost += card.defBoost
            }
            
                //Heal
            if card.healPower > 0 && battleEnemy.currentHP < battleEnemy.maxHP{
                battleEnemy.currentHP += card.healPower
                if battleEnemy.currentHP > battleEnemy.maxHP {
                    battleEnemy.currentHP = battleEnemy.maxHP
                }
            }
            
                //Steal Energy
            if card.stealPower > 0 {
                battlePlayer.currentEnergy -= card.stealPower
                if battlePlayer.currentEnergy < 0 {
                    battlePlayer.currentEnergy = 0
                }
                
                battleEnemy.currentEnergy += card.stealPower
                if battleEnemy.currentEnergy > battleEnemy.maxEnergy {
                    battleEnemy.currentEnergy = battleEnemy.maxEnergy
                }
            }
            
            //Put card in discard pile
            battleEnemy.AddCardtoDiscardPile(card: card, deckIndex: deckIndex)
        
            return true
            
    }
    
    
}

