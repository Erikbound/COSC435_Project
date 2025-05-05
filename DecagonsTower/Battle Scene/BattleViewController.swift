//
//  BattleViewController.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/29/25.
//

import UIKit
import SpriteKit
import GameplayKit
import Foundation
import SwiftUI

class BattleViewController: UIViewController {
    #warning("CALL COMPLETION WHEN BATTLE ENDS TO END GAME")
    var completion: ((BattleResult) -> Void)?
    
    var battlePlayer = BattlePlayerClass()
    var battleEnemy = BattleEnemyClass()

    
    //View Functions
    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = BattleScene(size: skView.bounds.size)
        scene.scaleMode = .aspectFill
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        //  Use Card Button Settings
        UseCardButtonOutlet.isEnabled = false
        UseCardButtonOutlet.alpha = 0.90
        
        //  Card Description settings
        CardDescription.numberOfLines = 5
        CardDescription.adjustsFontSizeToFitWidth = true
        
        //  End Turn Button
        EndTurnButtonOutlet.tintColor = .systemRed
        
        //  Textbox Settings
        Textbox.backgroundColor = .systemGray6
        Textbox.numberOfLines = 2
        
        //Used Card Display
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("PlayerHPLabel is \(PlayerHPLabel != nil ? "connected" : "nil")")
        //print("PlayerCard1 is \(PlayerCard1 != nil ? "connected" : "nil")")
        CheckBattleState(state: battleState.playerTurn)
        setCards()
        
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    
    //View Objects

    @IBOutlet weak var PlayerHPLabel: UILabel!
    @IBOutlet weak var PlayerEnergyLabel: UILabel!
    @IBOutlet weak var PlayerCardsLeft: UILabel!
    
    @IBOutlet weak var EnemyHPLabel: UILabel!
    @IBOutlet weak var EnemyEnergyLabel: UILabel!
    
    @IBOutlet weak var PlayerCard1: UIImageView!
    @IBOutlet weak var PlayerCard2: UIImageView!
    @IBOutlet weak var PlayerCard3: UIImageView!
    
    @IBOutlet weak var UseCardButtonOutlet: UIButton!
    @IBOutlet weak var EndTurnButtonOutlet: UIButton!
    
    @IBOutlet weak var CardDescription: UILabel!
    
    @IBOutlet weak var EnemyCard1: UIImageView!
    @IBOutlet weak var EnemyCard2: UIImageView!
    @IBOutlet weak var EnemyCard3: UIImageView!
    
    @IBOutlet weak var UsedCard: UIImageView!
    var UsedCardPlayerStartingPoint: CGPoint = CGPoint(x: -112, y: 479)
    var UsedCardPlayerEndingPoint: CGPoint = CGPoint(x: 145, y: 200)
    var UsedCardEnemyStartingPoint: CGPoint = CGPoint(x: -112, y: -100)
    var UsedCardEnemyEndingPoint: CGPoint = CGPoint(x: 145, y: 200)
    
    @IBOutlet weak var skView: SKView!
    
    var selectedCardTag: Int = 0
    enum battleState{
        case playerTurn
        case enemyTurn
        case playerWin
        case playerLose
    }
    var currentBattleState = battleState.playerTurn
    @IBOutlet weak var Textbox: UILabel!
    
    
    func UpdateUI(){
        PlayerHPLabel.text = "HP: \(battlePlayer.currentHP)/\(battlePlayer.maxHP)"
        PlayerEnergyLabel.text = "Energy: \(battlePlayer.currentEnergy)/\(battlePlayer.maxEnergy)"
        PlayerCardsLeft.text = "Cards Left: \(battlePlayer.deck.count)"
        
        EnemyHPLabel.text = "HP: \(battleEnemy.currentHP)/\(battleEnemy.maxHP)"
        EnemyEnergyLabel.text = "Energy: \(battleEnemy.currentEnergy)/\(battleEnemy.maxEnergy)"
        
            //Set the Image to the respective Player card
        if battlePlayer.hand.count > 0{
            PlayerCard1.image = UIImage(named: battlePlayer.hand[0].name)
        } else{
            PlayerCard1.image = UIImage(named: "Empty Card")
        }
        
        if battlePlayer.hand.count > 1{
            PlayerCard2.image = UIImage(named: battlePlayer.hand[1].name)
        } else{
            PlayerCard2.image = UIImage(named: "Empty Card")
        }
        
        if battlePlayer.hand.count > 2{
            PlayerCard3.image = UIImage(named: battlePlayer.hand[2].name)
        } else{
            PlayerCard3.image = UIImage(named: "Empty Card")
        }
        
        
            //Set the Image to the respective Enemy card
        if battleEnemy.hand.count > 0{
            EnemyCard1.image = UIImage(named: battleEnemy.hand[0].name)
        } else{
            EnemyCard1.image = UIImage(named: "Empty Card")
        }
        
        if battleEnemy.hand.count > 1{
            EnemyCard2.image = UIImage(named: battleEnemy.hand[1].name)
        } else{
            EnemyCard2.image = UIImage(named: "Empty Card")
        }
        
        if battleEnemy.hand.count > 2{
            EnemyCard3.image = UIImage(named: battleEnemy.hand[2].name)
        } else{
            EnemyCard3.image = UIImage(named: "Empty Card")
        }
        
        
        
//            //Keep all of the enemy's cards hidden
//        EnemyCard1.image = UIImage(named:"Empty Card")
//        EnemyCard2.image = UIImage(named:"Empty Card")
//        EnemyCard3.image = UIImage(named:"Empty Card")
        
        
    }
    
    
    func setCards(){
        UpdateUI()
        
        // Enable user interaction
        PlayerCard1.isUserInteractionEnabled = true
        PlayerCard2.isUserInteractionEnabled = true
        PlayerCard3.isUserInteractionEnabled = true
        
        // Add tap gestures
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
        
        PlayerCard1.tag = 0
        PlayerCard2.tag = 1
        PlayerCard3.tag = 2

        PlayerCard1.addGestureRecognizer(tap1)
        PlayerCard2.addGestureRecognizer(tap2)
        PlayerCard3.addGestureRecognizer(tap3)
    }
    
        //When a card is tapped, highlight it
    @objc func cardTapped(_ sender: UITapGestureRecognizer) {
        if currentBattleState == battleState.playerTurn {
                //Track which card was selected
            guard let tappedCard = sender.view as? UIImageView else { return }
            selectedCardTag = tappedCard.tag
            
            //#warning("App crashed here - tried to access index 1 when array had 1 item")
            if tappedCard.tag >= battlePlayer.hand.count {
                let cardIndex = battlePlayer.hand.count - 1
                battlePlayer.selectedCard = battlePlayer.hand[cardIndex]
            } else {
                battlePlayer.selectedCard = battlePlayer.hand[tappedCard.tag]
            }
            
            if battlePlayer.selectedCard!.energyCost <= battlePlayer.currentEnergy {
                UseCardButtonOutlet.isEnabled = true
                UseCardButtonOutlet.alpha = 1
                CardDescription.text = GetCardDescription(card: battlePlayer.hand[tappedCard.tag])
            } else {
                CardDescription.text = "Not enough energy to use card!"
            }
        }
    }
    
    
    @IBAction func UseCardButton(_ sender: Any) {
        guard let selectedCard = battlePlayer.selectedCard else { return }
        
        // Use the card
        PlayerUseCard(card: selectedCard, deckIndex: selectedCardTag)
        
        UsedCard.image = UIImage(named: selectedCard.name)
        
        // Animate Card
        UsedCard.isHidden = false
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 1.0,
                       options: [],
                       animations: { [self] in
            UsedCard.frame.origin = UsedCardPlayerEndingPoint
        }){ _ in
            // Wait 1 second after animation finishes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [self] in
                UsedCard.isHidden = true
                UsedCard.frame.origin = UsedCardEnemyStartingPoint
                
                UpdateUI()
                    //Change Turns
                if battleEnemy.currentHP > 0 && battlePlayer.hand.count > 0{
                    currentBattleState = battleState.enemyTurn
                    CheckBattleState(state: battleState.enemyTurn)
                }
                else {
                    if battleEnemy.currentHP == 0 {
                        Textbox.text = "The enemy has been defeated!"
                        CheckBattleState(state: battleState.playerWin)
                        UpdateUI()
                        completion?(.init(cardsWon: Int.random(in: 2...3), didWin: true))
                    } else if battlePlayer.hand.count == 0 {
                        Textbox.text = "You're out of cards!\nYou have lost."
                        CheckBattleState(state: battleState.playerLose)
                        UpdateUI()
                        completion?(.init(cardsWon: 0, didWin: false))
                    }
                }
            }
        }
        
        // Clear Description
        CardDescription.text = ""
        Textbox.text = "You used\n\(selectedCard.name)!"
        
        //print("Card used: \(selectedCard.name)")
        UseCardButtonOutlet.isEnabled = false
        UseCardButtonOutlet.alpha = 0.75
        
        EndTurnButtonOutlet.isEnabled = false
        EndTurnButtonOutlet.alpha = 0.75
    }
    
    @IBAction func EndTurnButton(_ sender: Any) {
            //End Turn without playing a card
        currentBattleState = battleState.enemyTurn
        CheckBattleState(state: battleState.enemyTurn)
        
        CardDescription.text = ""
        
        UsedCard.frame.origin = UsedCardEnemyStartingPoint
        
        EndTurnButtonOutlet.isEnabled = false
        EndTurnButtonOutlet.alpha = 0.75
    }
    
    
    func GetCardDescription(card: CardData) -> String {
        var desc: String = ""
        
        desc.append(card.name + "\nEnergy Cost: " + String(card.energyCost) + "\n")
        
        if card.atkPower > 0 {
            desc.append("Attack Power: " + String(card.atkPower) + "\n")
        }
        if card.healPower > 0 {
            desc.append("Recovers " + String(card.healPower) + " HP.\n")
        }
        if card.stealPower > 0 {
            desc.append("Steals " + String(card.stealPower) + " energy from opponent.\n")
        }
        
        if card.atkBoost > 0 {
            desc.append("Next attack does " + String(card.atkBoost) + " more damage.\n")
        }
        if card.defBoost > 0 {
            desc.append("Enemy's next attack does " + String(card.defBoost) + " less damage.\n")
        }
        
        
        return desc
    }

}
