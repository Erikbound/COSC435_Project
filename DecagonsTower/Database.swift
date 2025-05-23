//
//  Database.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//

import Foundation
import FirebaseFirestore

class Database {
    static func isUserNameAvailable(username: String) async throws -> Bool {
        let usersRef = Firestore.firestore().collection("users")
        let documents = try await usersRef.getDocuments()
        for document in documents.documents {
            if let exisitngUsername = document.data()["username"] as? String,
               exisitngUsername == username {
                return false
            }
        }
        return true
    }
    
    static func addUser(id: String, email: String, username: String) throws {
        let user = DTUser(id: id, email: email, username: username)
        let usersRef = Firestore.firestore().collection("users")
        try usersRef.document(id).setData(from: user)
    }
    
    static func fetchPlayers() async throws -> [DTUser] {
        let usersRef = Firestore.firestore().collection("users")
        let snapshot = try await usersRef.getDocuments()
        return snapshot.documents.compactMap {
            do {
                return try $0.data(as: DTUser.self)
            } catch {
                print(#function)
                print(error.localizedDescription)
                print(error)
                return nil
            }
        }
    }
    
    static func updatePlayer(for battleResult: BattleResult, userID: String) async throws {
        do {
            let userRef = Firestore.firestore().collection("users").document(userID)
            let userDoc = try await userRef.getDocument()
            let user = try userDoc.data(as: DTUser.self)
            user.cardsCollected += battleResult.cardsWon
            if battleResult.didWin {
                user.enemiesDefeated += 1
            }
            try userRef.setData(from: user)
        } catch {
            print(error.localizedDescription)
            print(error)
            
        }
    }
}
