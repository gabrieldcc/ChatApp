//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 29/06/24.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photo: String
    var senderId: String
    var displayName: String
}

class ChatViewController: MessagesViewController {
    
    private var messages = [MessageType]()
    
    private let selfSender = Sender(photo: "", senderId: "1", displayName: "Joe Smith")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        messages.append(Message(sender: selfSender, 
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello world message")))
        
        messages.append(Message(sender: selfSender, 
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello world message ello world message ello world message")))
        
        messagesCollectionView.reloadData()
        
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    var currentSender: SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
