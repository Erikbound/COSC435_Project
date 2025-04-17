//
//  AppDelegate.swift
//  DecagonsTower
//
//  Created by Jeryle Assension on 3/1/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        //Uncomment this line to set the view back to the game view
        //window?.rootViewController = GameViewController()
        
        //Comment these lines out too
        //
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let battleVC = storyboard.instantiateViewController(withIdentifier: "BattleViewController") as! BattleViewController
        //
        
        window?.rootViewController = battleVC
        window?.makeKeyAndVisible()
        return true
    }
}

    // MARK: UISceneSession Lifecycle (only if SceneDelegate.swift exists)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when user discards scene sessions.
    }

