//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    private var loginObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification,
                                                               object: nil,
                                                               queue: .main) { [weak self] _ in
            self?.navigationController?.dismiss(animated: true)
        }
        
        GIDSignIn.sharedInstance.signIn(withPresenting: self)
        
        title = "Login"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cadastrar",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped),
                              for: .touchUpInside)
        
        googleLoginButton.addTarget(self,
                              action: #selector(googleSigin),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        ///subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
        scrollView.addSubview(googleLoginButton)
        
        facebookLoginButton.delegate = self
    }
    
    deinit {
        if let observer = loginObserver {
            NotificationCenter.default.removeObserver(observer)
        }
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
        
        facebookLoginButton.frame = CGRect(x: 30,
                                   y: loginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        facebookLoginButton.center = scrollView.center
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
        
        googleLoginButton.frame = CGRect(x: 30,
                                   y: facebookLoginButton.bottom+10,
                                   width: scrollView.width-60,
                                   height: 52)
        
        googleLoginButton.center = scrollView.center
        googleLoginButton.frame.origin.y = facebookLoginButton.bottom+20
        
        
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
        component.tintColor = .black
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
        component.tintColor = .black
       return component
    }()
    
    private let facebookLoginButton: FBLoginButton =  {
        let component = FBLoginButton()
        component.permissions = ["email", "public_profile"]
        component.layer.cornerRadius = 12
        return component
    }()
    
    private let googleLoginButton: GIDSignInButton =  {
        let component = GIDSignInButton()
        component.style = .wide
        component.layer.cornerRadius = 12
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


//MARK: Facebook Login
extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginKit.FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBSDKLoginKit.FBLoginButton, didCompleteWith result: FBSDKLoginKit.LoginManagerLoginResult?, error: Error?) {
        
        guard let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        facebookRequest.start { connection, result, error in
            guard let result = result as? [String: Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            print("\(result)")
            
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                      print("Failed to get email and name from facebook result")
                      return
                  }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: user)
                }
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                
                guard authResult != nil, error == nil else {
                    if let error = error {
                        print("Facebook credential login failed, MFA may be needed \(error)")
                    }
                    return
                }
                
                print("Successfully logged user in")
                self?.navigationController?.dismiss(animated: true)
            }
        }
    }
        
}

//MARK: - Google Sigin
extension LoginViewController {
    
    @objc func googleSigin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else { return }
            guard let idToken = signInResult?.user.idToken?.tokenString,
                  let accessToken = signInResult?.user.accessToken.tokenString,
                  let email = signInResult?.user.profile?.email,
                  let firstName =  signInResult?.user.profile?.givenName,
                  let lastName = signInResult?.user.profile?.familyName,
                  let user = signInResult?.user
            else { return }
            
            print("Did Sigin with Google: \(user)")
            
            DatabaseManager.shared.userExists(with: email) { exists in
                if !exists {
                    //insert to database
                    let user = ChatAppUser(firstName: firstName, lastName: lastName, emailAdress: email)
                    DatabaseManager.shared.insertUser(with: user)
                }
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
            
            FirebaseAuth.Auth.auth().signIn(with: credential) { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Failed to Log In with Google Credential")
                    return
                }
                print("Successfully to Sign In with Google Credential")
                NotificationCenter.default.post(name: .didLogInNotification, object: nil)
            }
            
            print("Login Google Success: \(signInResult)")
          // If sign in succeeded, display the app's main content View.
        }
    }
    
}
