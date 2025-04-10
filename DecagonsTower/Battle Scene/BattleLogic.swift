//
//  BattleLogic.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/27/25.
//

    
extension BattleViewController {
    
    func startBattle(){
        
        PlayerHPLabel.text = "HP: \(battlePlayer.currentHP)/\(battlePlayer.maxHP)"
        PlayerEnergyLabel.text = "Energy: \(battlePlayer.currentEnergy)/\(battlePlayer.maxEnergy)"
        
        EnemyHPLabel.text = "HP: \(battleEnemy.currentHP)/\(battleEnemy.maxHP)"
        EnemyEnergyLabel.text = "Energy: \(battleEnemy.currentEnergy)/\(battleEnemy.maxEnergy)"
        
        
            //Start Turn 1
        ExecutePlayerTurn()
    }

    func ExecutePlayerTurn(){
        battlePlayer.DrawCardFromDeck()
        battlePlayer.AddEnergy(amount: 1)
        //Wait for player to select card or end turn
        //if selectedCard.energyCost <= energy{
            //UseCard()
        //}
    }
    
    func ExecuteEnenemyTurn(){
        
    }
    
    
    
    
    
}

