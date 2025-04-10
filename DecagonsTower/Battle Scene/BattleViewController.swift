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
        
        if let view = self.view as? SKView {
            // Load the SKScene from 'GameScene.sks'

            if let scene = SKScene(fileNamed: "BattleScene") {
                    // Set the scale mode to scale to fit the window
                scene.scaleMode = .aspectFill
                
                // Present the scene
                view.presentScene(scene)
            }
                
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        startBattle()
        //setCards()
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
    
    @IBOutlet weak var PlayerCard1: UIImageView!
    @IBOutlet weak var PlayerCard2: UIImageView!
    @IBOutlet weak var PlayerCard3: UIImageView!
    
    
    @IBOutlet weak var EnemyHPLabel: UILabel!
    @IBOutlet weak var EnemyEnergyLabel: UILabel!
    
    
//    func setCards(){
//        PlayerCard1.image = UIImage(named: battlePlayer.deck[0].name)
//        PlayerCard2.image = UIImage(named: battlePlayer.deck[1].name)
//        PlayerCard3.image = UIImage(named: battlePlayer.deck[2].name)
//    }
   
    
}
