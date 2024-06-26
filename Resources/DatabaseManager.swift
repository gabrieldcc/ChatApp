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
    
    static func safeEmail(emailAdress: String) -> String {
        let safeEmail = emailAdress
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
   
}

    //MARK: Account Management
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        let safeEmail = email
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
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        
        database.child(user.safeEmaiil).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName,
        ]) { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollections = snapshot.value as? [[String: String]] {
                    //append to user dictionary
                    let newElement: [String: String] =
                        ["name": user.firstName + " " + user.lastName,
                         "email": user.safeEmaiil
                        ]
                    
                    usersCollections.append(newElement)
                    self.database.child("users").setValue(usersCollections, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                } else {
                    //create the array
                    let newCollection: [[String: String]] = [
                        ["name": user.firstName + " " + user.lastName,
                         "email": user.safeEmaiil
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
            })
            completion(true)
        }
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAdress: String
    
    var profilePictureFileName: String {
        return "\(safeEmaiil)_profile_picture.png"
    }
    
    var safeEmaiil: String {
        let safeEmail = emailAdress
            .replacingOccurrences(of: ".", with: "-")
            .replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
