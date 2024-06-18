//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit

class RegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Log in"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
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
        scrollView.addSubview(firstNameField)
        scrollView.addSubview(lastNameField)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(loginButton)
        
        imageView.isUserInteractionEnabled = true
        scrollView.isUserInteractionEnabled = true
        
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapChangeProfilePic))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        imageView.addGestureRecognizer(gesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        firstNameField.frame = CGRect(x: 30,
                                  y: imageView.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        
        lastNameField.frame = CGRect(x: 30,
                                  y: firstNameField.bottom+10,
                                  width: scrollView.width-60,
                                  height: 52)
        
        emailField.frame = CGRect(x: 30,
                                  y: lastNameField.bottom+10,
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
        component.contentMode = .scaleAspectFit
        component.image = UIImage(systemName: "person")
        component.tintColor = .gray
        return component
    }()
    
    private let firstNameField: UITextField = {
        let component = UITextField()
        component.autocapitalizationType = .none
        component.autocorrectionType = .no
        component.returnKeyType = .continue
        component.layer.cornerRadius = 12
        component.layer.borderWidth = 1
        component.layer.borderColor = UIColor.lightGray.cgColor
        component.placeholder = "Primeiro nome..."
        component.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        component.leftViewMode = .always
        component.backgroundColor = .white
        return component
    }()
    
    private let lastNameField: UITextField = {
        let component = UITextField()
        component.autocapitalizationType = .none
        component.autocorrectionType = .no
        component.returnKeyType = .continue
        component.layer.cornerRadius = 12
        component.layer.borderWidth = 1
        component.layer.borderColor = UIColor.lightGray.cgColor
        component.placeholder = "Último nome..."
        component.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 6, height: 0))
        component.leftViewMode = .always
        component.backgroundColor = .white
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
        component.setTitle("Cadastrar-se", for: .normal)
        component.backgroundColor = .systemGreen
        component.setTitleColor(.white, for: .normal)
        component.layer.masksToBounds = true
        component.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        component.layer.cornerRadius = 12
        return component
    }()
    
    @objc func didTapChangeProfilePic() {
        print("change pic")
    }
    
    @objc func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        
        guard let firstName = firstNameField.text,
              let lastName = lastNameField.text,
              let email = emailField.text,
              let password = passwordField.text,
              !firstName.isEmpty,
              !lastName.isEmpty,
              !email.isEmpty,
              !password.isEmpty,
              password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        //Firebase Login
        
    }
    
    func alertUserLoginError() {
        let alert = UIAlertController(title: "Ops",
                                      message: "Coloque todas as informações corretas para fazer criar a sua conta",
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

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            
            loginButtonTapped()
        }
        
        return true
    }
    
}



