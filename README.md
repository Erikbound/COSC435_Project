# COSC435_Project
# COSC435_Project
# COSC435_Project
# Decagon’s Tower

Decagon's Tower is a top-down RPG game built with **Swift**, **SpriteKit**, and **Firebase**.  
Players will explore the tower, solve riddles, fight enemies using cards, and collect rewards to progress deeper into the tower.

## 🎮 Features

- Procedurally generated levels and exploration
- Interactive NPCs (e.g. Wolf NPC for riddles)
- Battle system with cards (Hit, Repel, Healing, Laser, etc.)
- Card animations and turn-based combat
- Enemy AI logic
- Castle interior scene with transitions and background music
- Game Over screen with replay option and leaderboard access
- Firebase integration for user authentication and leaderboard management

## 🚀 Technologies Used

- **Swift** (main programming language)
- **SpriteKit** (2D graphics and game logic)
- **Firebase** (Authentication and Leaderboard)
- **Xcode** (iOS development)
- **AVFoundation** (audio playback)

## 📦 Project Structure

- `GameScene.swift` → Main overworld scene logic (movement, wolf riddle interaction)
- `CastleInteriorScene.swift` → Castle interior and transition logic
- `BattleViewController.swift` → Battle scene handling, card usage, win/loss determination
- `GameOverView.swift` → Game Over view with play again option
- `Leaderboard` → Firebase-based leaderboard display
- `Authentication.swift` and `AuthenticationView.swift` → User login/signup with Firebase
- `Assets.xcassets` and `sounds` → Game assets (sprites, sounds, music)

## 👥 Team & Responsibilities
## 👥 Team & Responsibilities

### Mu Mung (Art & Systems Integration)
- Designed and created the sign in and sign up system using Firebase Authentication.
- Drew and implemented art for the game scene, castle scene, wolf NPC, and riddle UI.
- Placed boundaries around the castle and inside the castle to control player movement.
- Added the leaderboard system with Firebase integration.
- Developed the Game Over view for handling player defeat and victory scenarios.

### Erik (Battle System and Cards)
- Implemented the player character.
- Developed the card system and turn-based battle logic.
- Created and animated various battle cards .
- Built the core card usage mechanics and player-enemy interaction during battles.

### Jaryl (Enemy and character movement and Gameplay Enhancements)
- Updated the wolf NPC interactions into animated version. 
- Upgraded the enemy knight with a "Run or Fight" choice mechanic for dynamic encounters.
- Improve player and enemy knight movements.
