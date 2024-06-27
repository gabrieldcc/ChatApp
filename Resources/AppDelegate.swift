//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Gabriel de Castro Chaves on 18/06/24.
//

import UIKit
import FBSDKCoreKit
import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? ) -> Bool {
    
    ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    
    FirebaseApp.configure()
    guard let clientID = FirebaseApp.app()?.options.clientID else {
        fatalError("No client ID found in Firebase Configuration")
    }
    
    let config = GIDConfiguration(clientID: clientID)
    
    GIDSignIn.sharedInstance.configuration = config
    
    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
        if error != nil || user == nil {
          // Show the app's signed-out state.
        } else {
          // Show the app's signed-in state.
        }
      }
    
    return true
}
      
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool {
        
        ApplicationDelegate.shared.application(app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation])
        
        var handled: Bool

          handled = GIDSignIn.sharedInstance.handle(url)
          if handled {
            return true
          }
        
        return true
    }
}


