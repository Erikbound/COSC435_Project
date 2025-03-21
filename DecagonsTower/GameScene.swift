//
//  GameScene.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 3/1/25.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var player: SKSpriteNode! //Creates player character sprite
    var tileMap: SKTileMapNode! //Crates a tiled map
    
    //Called when the scene is first presented to the view
    override func didMove(to view: SKView) {
        setupScene()
        setupTileMap()
    }
    
    //Sets map as a big green tile, player character as a small blue tile,
    //and places player on the map
    func setupScene() {
        backgroundColor = .green
        
        player = SKSpriteNode(color: .blue, size: CGSize(width: 40, height: 40))
        player.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(player)
    }
    
    //Setup for tiled map
    func setupTileMap() {
        tileMap = childNode(withName: "TileMap") as? SKTileMapNode
    }
    
    //Player movements are determined by touching specific tile on screen
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        movePlayer(to: location)
    }
    
    //Moves players to that tile and plays animation
    func movePlayer(to position: CGPoint) {
        let moveAction = SKAction.move(to: position, duration: 0.5)
        player.run(moveAction)
    }
    
    
}
