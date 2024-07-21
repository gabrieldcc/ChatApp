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

    //MARK: Sending messages / conversations
extension DatabaseManager {
    
    /// Creates a new convesation with target user, email and first message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping(Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentEmail)
        let ref =  database.child("\(safeEmail)")
        ref.observeSingleEvent(of: .value, with: { snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                    
                ]
            ]
            
            let recipient_newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": "Self",
                "latest_message": [
                    "date": dateString,
                    "message": message, 
                    "is_read": false,
                    
                ]
            ]
            
            //Update recipient conversation
            self.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: {
                [weak self] snapshot in
                if var conversations = snapshot.value as? [[String: Any]] {
                    //append
                    conversations.append(recipient_newConversationData)
                    self?.database.child("\(otherUserEmail)/conversations").setValue(conversationID)
                } else {
                    //create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversationData])
                }
            })
            
            //Update current user conversation entry
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                //conversation array exists for current user
                //you should append
                
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
                
            } else {
               //conversation array does NOT exist
                //create it
                userNode["conversations"] = [
                    newConversationData
                ]
                
                ref.setValue(userNode, withCompletionBlock: { [weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: currentUserEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": safeEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        print("adding conversation: \(conversationID)")
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: { error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping(Result<[Conversation], Error>) -> Void) {
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap { dictionary in
                
                guard    let conversationId = dictionary["id"] as? String,
                         let name = dictionary["name"] as? String,
                         let otherUserEmail = dictionary["other_user_email"] as? String,
                         let latestMessage = dictionary["latest_message"] as? [String: Any],
                         let date = latestMessage["date"] as? String,
                         let message = latestMessage["message"] as? String,
                         let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }

                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                    
                return Conversation(id: conversationId, name: name, 
                                    otherUserEmail: otherUserEmail,
                                    latestMessage: latestMessageObject)
            }
            completion(.success(conversations))
        })
    }
                                                         
    
    /// Gets all messages for given conversation
    public func getAllMessagesForConversations(with id: String, completion: @escaping(Result<[Message], Error>) -> Void) {
        database.child("\(id)/messages").observe(.value, with: { snapshot in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({ dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String ,
                      let date = ChatViewController.dateFormatter.date(from: dateString) else {
                    return nil
                }
                
                let sender = Sender(photo: "",
                                    senderId: senderEmail, 
                                    displayName: name)
                
                return Message(sender: sender,
                               messageId: messageID,
                               sentDate: date,
                               kind: .text(content))
            })
            completion(.success(messages))
        })
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message, completion: @escaping(Bool) -> Void) {
        
    }
}

extension DatabaseManager {
    
    func getUserDefaultDirectories() {
        if let directory = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first {
            print("Library Directory: \(directory)")
            
            let preferencesPath = directory.appendingPathComponent("Preferences")
            print("Preferences Directory: \(preferencesPath)")

            let userDefaultsFilePath = preferencesPath.appendingPathComponent("\(Bundle.main.bundleIdentifier!).plist")
            print("UserDefaults File Path: \(userDefaultsFilePath)")
        }
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
