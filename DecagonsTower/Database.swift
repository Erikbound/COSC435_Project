//
//  Database.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//

import Foundation
import FirebaseFirestore

class DTUser: Codable {
    let id: String
    let email: String
    let username: String
    let enemiesDefeated: Int
    let cardsCollected: Int
    
    init(
        id: String,
        email: String,
        username: String,
        enemiesDefeated: Int = 0,
        cardsCollected: Int = 0
    ) {
        self.id = id
        self.email = email
        self.username = username
        self.enemiesDefeated = enemiesDefeated
        self.cardsCollected = cardsCollected
    }
}

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
        try usersRef.addDocument(from: user)
    }
}
