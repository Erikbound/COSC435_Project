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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("PlayerHPLabel is \(PlayerHPLabel != nil ? "connected" : "nil")")
        print("PlayerCard1 is \(PlayerCard1 != nil ? "connected" : "nil")")
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
    
    
    @IBOutlet weak var skView: SKView!
    
    func setCards(){
        PlayerCard1.image = UIImage(named: battlePlayer.deck[0].name)
        PlayerCard2.image = UIImage(named: battlePlayer.deck[1].name)
        PlayerCard3.image = UIImage(named: battlePlayer.deck[2].name)
    }
    
    
}
