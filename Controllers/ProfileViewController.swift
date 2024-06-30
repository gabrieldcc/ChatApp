//
//  ProfileViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    
    let data = ["Log out"]

    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableHeaderView = createTableHeader()
    }
    
    func createTableHeader() -> UIView? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAdress: email)
        let fileName = safeEmail + "_profile_picture.png"
        let path = "images/" + fileName
        
        let headerView = UIView(frame: (CGRect(x: 0, 
                                               y: 0,
                                               width: self.view.width,
                                               height: 300)))
        headerView.backgroundColor = .link
        let imageView = UIImageView(frame: CGRect(x: (headerView.width-150) / 2, 
                                                  y: 75,
                                                  width: 150,
                                                  height: 150))
        imageView.backgroundColor = .white
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        
        StorageManager.shared.downloadUrl(for: path, completion: { result in
            switch result {
            case .success(let url):
                self.downloadImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })

        return headerView
    }
    
    func downloadImage(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }).resume()
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let actionSheet = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Sair", style: .destructive, handler: { [weak self] _ in
            
            //Logout Facebook
            FBSDKLoginKit.LoginManager().logOut()
            
            //Logout Google
            GIDSignIn.sharedInstance.signOut()
            
            do {
                try FirebaseAuth.Auth.auth().signOut()
                
                let vc = LoginViewController()
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .fullScreen
                self?.present(nav, animated: false)
            } catch {
                print("Failed to Log out")
            }
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
        
    }
    
    
}
