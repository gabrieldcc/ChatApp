//
//  NewConversationViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    private let searchBar: UISearchBar = {
        let component = UISearchBar()
        component.placeholder = "Busque por contatos"
        return component
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.backgroundColor = .white
        navigationController?.navigationBar.topItem?.titleView = searchBar
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancelar", style: .done, target: self, action: #selector(dismissSelf))
    }
    
    @objc func dismissSelf() {
        dismiss(animated: true)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
    }
}
