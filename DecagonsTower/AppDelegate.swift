//
//  AppDelegate.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 3/1/25.
//

import UIKit
import FirebaseCore
import SwiftUI

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var loggedInUserID: String?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        FirebaseApp.configure()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIHostingController(rootView: AuthenticationView(didLogIn: didLogIn))
        
        
        //Comment these lines out too
        //
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
//        window?.rootViewController = battleVC
        //
        
        
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func didLogIn(userID: String) {
        loggedInUserID = userID
        showGameViewController()
    }
    
    private func showGameViewController() {
        window?.rootViewController = GameViewController(completion: gameDidEnd)
    }
    
    private func gameDidEnd(battleResult: BattleResult) {
        Task {
            if let loggedInUserID {
                do {
                    try await Database.updatePlayer(for: battleResult, userID: loggedInUserID)
                } catch {
                    print(error)
                    print(error.localizedDescription)
                }
            }
            
            await MainActor.run {
                let gameOverView = GameOverView(playAgain: playAgain, showLeaderboard: showLeaderboard)
                window?.rootViewController = UIHostingController(rootView: gameOverView)
            }
        }
    }
    
    private func playAgain() {
        showGameViewController()
    }
    
    private func showLeaderboard() {
        guard let rootVC = window?.rootViewController else {
            print("root view controller was nil")
            return
        }
        
        let leaderboardVC = UIHostingController(rootView: LeaderboardView())
        rootVC.present(leaderboardVC, animated: true)
    }
}

    // MARK: UISceneSession Lifecycle (only if SceneDelegate.swift exists)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when user discards scene sessions.
    }

