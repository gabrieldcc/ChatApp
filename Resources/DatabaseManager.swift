//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 20/06/24.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
   
}

    //MARK: Account Management
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        var safeEmail = email
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
        }
        
    }
    
    ///inserts new user to database
    public func insertUser(with user: ChatAppUser) {
        
        database.child(user.safeEmaiil).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName,
        ])
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAdress: String
    //let profilePictureUrl: String
    
    var safeEmaiil: String {
        let safeEmail = emailAdress
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
