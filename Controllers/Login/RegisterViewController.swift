//
//  RegisterViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Login"
        view.backgroundColor = .white
        
        registerButton.addTarget(self,
                              action: #selector(registerButtonTapped),
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
        scrollView.addSubview(registerButton)
        scrollView.addSubview(registerButton)
        
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
        
        imageView.layer.cornerRadius = imageView.width/2.0
        
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
        
        registerButton.frame = CGRect(x: 30,
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
        component.image = UIImage(systemName: "person.circle")
        component.tintColor = .gray
        component.layer.masksToBounds = true
        component.layer.borderWidth = 2
        component.layer.borderColor = UIColor.lightGray.cgColor
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
        component.text = "Gabriel"
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
        component.text = "Catro"
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
        component.text = "gabrieldcc@gmail.com"
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
        component.text = "Gabriel98$"
        return component
    }()
    
    private let registerButton: UIButton = {
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
        presentPhotoActionSheet()
    }
    
    @objc func registerButtonTapped() {
        
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
            alertUserLoginError(message: "Coloque todas as informações corretas para fazer criar a sua conta")
            return
        }
        
        //Firebase Login
        
        DatabaseManager.shared.userExists(with: email) { [weak self] exists in
            guard !exists else {
                self?.alertUserLoginError(message: "Parece que já existe um usuário com este e-mail")
                return
            }
            
            
        }
        
        FirebaseAuth.Auth.auth().createUser(withEmail: email,
                                            password: password,
                                            completion: { [weak self] authResult, error  in
            
            guard let strongSelf = self else {
                return
            }
            
            guard authResult != nil, error == nil else {
                print("Error creating user")
                return
            }
            
            let user = ChatAppUser(firstName: firstName,
                                   lastName: lastName,
                                   emailAdress: email)
            
            DatabaseManager.shared.insertUser(with: user)
            
            print("Created user: \(user)")
            strongSelf.navigationController?.dismiss(animated: true)
        })
        
    }
    
    // "Coloque todas as informações corretas para fazer criar a sua conta"
    
    func alertUserLoginError(message: String) {
        let alert = UIAlertController(title: "Ops",
                                      message: message,
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
            
            registerButtonTapped()
        }
        
        return true
    }
    
}

extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Foto de Perfil", 
                                            message: "Como você quer selecionar uma foto de perfil?",
                                            preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Cancelar", 
                                            style: .cancel,
                                            handler: nil))
        
        actionSheet.addAction(UIAlertAction(title: "Tirar foto",
                                            style: .default,
                                            handler: { [weak self] _ in self?.presentCamera() }) )
        
        actionSheet.addAction(UIAlertAction(title: "Escolher uma foto", 
                                            style: .default,
                                            handler:  { [weak self] _ in self?.presentPhotoPicker() }) )
        present(actionSheet, animated: true)
    }
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
       
        self.imageView.image = selectedImage
    }
}



