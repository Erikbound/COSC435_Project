//
//  BattleScene.swift
//  DecagonsTower
//
//  Created by Erik Umoh on 4/15/25.
//

import Foundation
import SpriteKit
import GameplayKit

class BattleScene: SKScene{
    
    override func didMove(to view: SKView) {
        addBackground()
    }
    
    
    func addBackground(){
        let bg = SKSpriteNode(imageNamed: "BattleBackground") // Make sure "map" is added to Assets
        
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size = CGSize(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height )
        
        addChild(bg)
    }
    
    
    
    
    
    
    //    func setCards(){
    //        PlayerCard1.image = UIImage(named: battlePlayer.deck[0].name)
    //        PlayerCard2.image = UIImage(named: battlePlayer.deck[1].name)
    //        PlayerCard3.image = UIImage(named: battlePlayer.deck[2].name)
    //    }
}
