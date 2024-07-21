//
//  ViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FirebaseAuth
import JGProgressHUD
import SwiftUI

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var conversations: [Conversation] = []
    
    private let tableView: UITableView = {
        let component = UITableView()
        component.isHidden = true
        component.register(ConversationTableViewCell.self, 
                           forCellReuseIdentifier: ConversationTableViewCell.identifier)
        return component
    }()
    
    private let noConversationsLabel: UILabel = {
       let component = UILabel()
        component.text = "No conversations!"
        component.textAlignment = .center
        component.textColor = .gray
        component.font = .systemFont(ofSize: 21, weight: .medium)
        component.isHidden = true
        return component
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(didTapComposeButton))
        view.addSubview(tableView)
        view.addSubview(noConversationsLabel)
        setupTableView()
        fetchConversations()
        startListeningForConversations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validateAuth()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    func validateAuth() {
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    private func startListeningForConversations() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        print("starting conversation fetch...")
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        
        DatabaseManager.shared.getAllConversations(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                print("successfuly got conversation models")
                guard !conversations.isEmpty else {
                    return
                }
                self?.conversations = conversations
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("failed to get conversations: \(error)")
            }
        })
    }
    
    @objc func didTapComposeButton() {
        let vc = NewConversationViewController()
        vc.completion = { [weak self] result in
            print("\(result)")
            self?.createNewConversation(result: result)
        }
        let navVC = UINavigationController(rootViewController: vc)
        present(navVC, animated: true)
    }
     
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        let vc = ChatViewController(with: email, id: nil)
        vc.isNewConversation = true
        vc.title = name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func fetchConversations() {
        tableView.isHidden = false
    }

}

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let model = conversations[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.identifier, 
                                                 for: indexPath) as! ConversationTableViewCell
        
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = conversations[indexPath.row]

        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ChatViewController(with: model.otherUserEmail, id: model.id)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
}

