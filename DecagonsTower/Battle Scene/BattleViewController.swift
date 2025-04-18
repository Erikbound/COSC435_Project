//
//  BattleViewController.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 3/29/25.
//

import UIKit
import SpriteKit
import GameplayKit

class BattleViewController: UIViewController {
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
        
        UseCardButtonOutlet.isEnabled = false
        UseCardButtonOutlet.alpha = 0.75
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //print("PlayerHPLabel is \(PlayerHPLabel != nil ? "connected" : "nil")")
        //print("PlayerCard1 is \(PlayerCard1 != nil ? "connected" : "nil")")
        startBattle()
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
    
    @IBOutlet weak var EnemyHPLabel: UILabel!
    @IBOutlet weak var EnemyEnergyLabel: UILabel!
    
    @IBOutlet weak var PlayerCard1: UIImageView!
    @IBOutlet weak var PlayerCard2: UIImageView!
    @IBOutlet weak var PlayerCard3: UIImageView!
    
    @IBOutlet weak var UseCardButtonOutlet: UIButton!
    
    
    @IBOutlet weak var CardDescription: UILabel!
    
    @IBOutlet weak var EnemyCard1: UIImageView!
    @IBOutlet weak var EnemyCard2: UIImageView!
    @IBOutlet weak var EnemyCard3: UIImageView!
    
    @IBOutlet weak var skView: SKView!
    
    
    
    func setCards(){
        
        CardDescription.numberOfLines = 5
        CardDescription.adjustsFontSizeToFitWidth = true
        
        PlayerCard1.image = UIImage(named: battlePlayer.deck[0].name)
        PlayerCard2.image = UIImage(named: battlePlayer.deck[1].name)
        PlayerCard3.image = UIImage(named: battlePlayer.deck[2].name)
        
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
        guard let tappedCard = sender.view as? UIImageView else { return }
        
        battlePlayer.selectedCard = battlePlayer.deck[tappedCard.tag]
        
        UseCardButtonOutlet.isEnabled = true
        UseCardButtonOutlet.alpha = 1
        
        CardDescription.text = GetCardDescription(card: battlePlayer.deck[tappedCard.tag])
    }
    
    
    @IBAction func UseCardButton(_ sender: Any) {
        guard let selectedCard = battlePlayer.selectedCard else { return }
        
        
        print("Card used: \(selectedCard.name)")
        UseCardButtonOutlet.isEnabled = false
        UseCardButtonOutlet.alpha = 0.75
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
