//
//  BattleLogic.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/27/25.
//

    
extension BattleViewController {
    
    func startBattle(){
        currentBattleState = battleState.playerTurn
            //Start Turn 1
        ExecutePlayerTurn()
    }

    func ExecutePlayerTurn(){
            //If you didn't play a card last turn, don't draw a card
        battlePlayer.DrawCardFromDeck()
        battlePlayer.AddEnergy(amount: 1)
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
        
        //End Turn
        currentBattleState = battleState.enemyTurn
        ExecuteEnemyTurn()
    }
    
    func ExecuteEnemyTurn(){
        Textbox.text = "The enemy is making their move..."
        currentBattleState = battleState.playerTurn
        ExecutePlayerTurn()
    }
    
    
    
    
    
}

