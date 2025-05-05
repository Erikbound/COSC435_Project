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
    
    var backgroundMusic: SKAudioNode?
    
    override func didMove(to view: SKView) {
        addBackground()
        playBGM()
    }
    
    func playBGM(){
        // ⏯️ Background music
        if let musicURL = Bundle.main.url(forResource: "BattleMusic", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic?.autoplayLooped = true
            addChild(backgroundMusic!)
        }
    }
    
    func playVictoryMusic(){
        // ⏯️ Background music
        if let musicURL = Bundle.main.url(forResource: "BattleVictory", withExtension: "mp3") {
            backgroundMusic = SKAudioNode(url: musicURL)
            backgroundMusic?.autoplayLooped = true
            addChild(backgroundMusic!)
            stopMusicAfterDelay(seconds: 14)
        }
    }
    
    func stopBGM(){
        backgroundMusic?.removeFromParent()
        backgroundMusic = nil
    }
    
    func stopMusicAfterDelay(seconds: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.backgroundMusic?.removeFromParent()
            self.backgroundMusic = nil
        }
    }
    
    
    func addBackground(){
        let bg = SKSpriteNode(imageNamed: "BattleBackground") // Make sure "map" is added to Assets
        
        bg.position = CGPoint(x: size.width / 2, y: size.height / 2)
        bg.size = CGSize(width: UIScreen.main.bounds.width, height:UIScreen.main.bounds.height )
        
        addChild(bg)
    }
    
}
