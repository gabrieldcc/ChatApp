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
    
    public func test() {
        
        database.child("foo").setValue( ["something": true] )
    }
}
