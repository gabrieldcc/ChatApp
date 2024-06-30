//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var users: [[String: String]] = []
    
    private var hasFetched: Bool = false
    
    private let searchBar: UISearchBar = {
        let component = UISearchBar()
        component.placeholder = "Busque por contatos"
        return component
    }()
    
    private let tableView: UITableView = {
        let component = UITableView()
        component.isHidden = true
        component.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .done, target: self, action: #selector(dismissSelf))
        searchBar.becomeFirstResponder()
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        spinner.show(in: view)
        
        self.searchUsers(query: text)
        
    }
    
    func searchUsers(query: String) {
        //check if array has firebase results
        if hasFetched {
            //if it does: filter
            DatabaseManager.shared.getAllUsers(completion: { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.users = usersCollection
                case .failure(let error):
                    print("Failed to get users: \(error)")
                }
            })
        } else {
            //if not, fetch then filter
        }
        //update the UI: either show or not results label
    }
}
