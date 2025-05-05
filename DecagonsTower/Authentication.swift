//
//  Authentication.swift
//  DecagonsTower
//
//  Created by Mu Mung on 4/23/25.
//

import Foundation
import FirebaseAuth

class Authentication {
    static func signUp(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            print(#function, "SUCCEDED")
            return result.user.uid
        } catch {
            print(#function, "FAILED")
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
    
    static func signIn(email: String, password: String) async throws  -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            print(#function, "SUCCEDED")
            print(result.user)
            return result.user.uid
        } catch {
            print(#function, "FAILED")
            print(error)
            print(error.localizedDescription)
            throw error
        }
    }
}
