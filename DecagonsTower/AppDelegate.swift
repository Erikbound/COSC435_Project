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

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UIHostingController(rootView: AuthenticationView(didLogIn: didLogIn))
        
        //window?.rootViewController = UIHostingController(rootView: LeaderboardView())
        
        
        
        FirebaseApp.configure()

        
        //Comment these lines out too
        //
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
//        window?.rootViewController = battleVC
        //
        
        
        window?.makeKeyAndVisible()
        return true
    }
    
    private func didLogIn() {
        window?.rootViewController = GameViewController()
    }
}

    // MARK: UISceneSession Lifecycle (only if SceneDelegate.swift exists)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when user discards scene sessions.
    }

