//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cadastrar",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        ///subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom+10,
                                     width: scrollView.width-60,
                                     height: 52)
        
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
    }
    
    
    private let scrollView: UIScrollView = {
        let component = UIScrollView()
        component.clipsToBounds = true
        return component
    }()
    
    private let imageView: UIImageView = {
        let component = UIImageView()
        component.image = UIImage(named: "logo-chat")
        component.contentMode = .scaleAspectFit
        component.layer.cornerRadius = 12
        component.clipsToBounds = true
       return component
    }()
    
    private let emailField: UITextField = {
        let component = UITextField()
        component.autocapitalizationType = .none
        component.autocorrectionType = .no
        component.returnKeyType = .continue
        component.layer.cornerRadius = 12
        component.layer.borderWidth = 1
        component.layer.borderColor = UIColor.lightGray.cgColor
        component.placeholder = "Seu email..."
        component.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        component.leftViewMode = .always
        component.backgroundColor = .white
       return component
    }()
    
    private let passwordField: UITextField = {
        let component = UITextField()
        component.autocapitalizationType = .none
        component.autocorrectionType = .no
        component.returnKeyType = .done
        component.layer.cornerRadius = 12
        component.layer.borderWidth = 1
        component.layer.borderColor = UIColor.lightGray.cgColor
        component.placeholder = "Senha..."
        component.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        component.leftViewMode = .always
        component.backgroundColor = .white
        component.isSecureTextEntry = true
       return component
    }()
    
    private let loginButton: UIButton = {
        let component = UIButton()
        component.setTitle("Login", for: .normal)
        component.backgroundColor = .link
        component.setTitleColor(.white, for: .normal)
        component.layer.masksToBounds = true
        component.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        component.layer.cornerRadius = 12
       return component
    }()
    
    @objc func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
           alertUserLoginErro2()
            return
        }
        
        //Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email,
                                        password: password,
                                        completion: { [weak self] authResult, error in
            
            guard let strongSelf = self else {
                return
            }
                
            guard let result = authResult, error == nil else {
                print("Failed to login user with email: \(email)")
                return
            }
            
            let user = result.user
            print("Logged in user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
                                            
        })
    }
    
    func alertUserLoginErro2() {
        let alert = UIAlertController(title: "Ops",
                                      message: "Coloque todas as informações corretas para fazer o log in",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true)
        
    }
    
    @objc func didTapRegister() {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
    
}
