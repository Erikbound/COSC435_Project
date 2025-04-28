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
        try usersRef.addDocument(from: user)
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
}
