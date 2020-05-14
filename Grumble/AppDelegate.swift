//
//  AppDelegate.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import UIKit
import GoogleSignIn
import Firebase

public var count: Int = 0

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    //Deprecated, but here for iOS 8 and lower
    @available(*, deprecated)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }
    
    //on GoogleSignIn Finish
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        LoginAccessCookie.lac().pendingGoogle = false
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("error :\(error)")
            }
            return
        }
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        Auth.auth().signIn(with: credential) { _, error in
            if let error = error {
                print("error:\(error)")
                return
            }
            
            var hasEmailProvider: Bool = false
            for provider in Auth.auth().currentUser!.providerData {
                if provider.providerID == EmailAuthProviderID {
                    hasEmailProvider = true
                    break
                }
            }
            
            if !hasEmailProvider {
                let linkToken: String = randomString(length: 10)
                UserCookie.uc().setLinkToken(linkToken)
                writeLocalData(DataListKeys.linkToken, linkToken)
                writeCloudData(DataListKeys.linkToken, linkToken)
                createLinkedAccount(pass: linkToken)
            }
            
            onLogin()
        }
    }
    
    //on Google SignOut
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!,
              withError error: Error!) {
    }

    //On application launch
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //initializers
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = "729013591612-1idpq36eenpo1at67i9dujmkrbuc5j68.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().delegate = self
        UserCookie.uc().setLoggedIn(Auth.auth().currentUser)
        
        if let uid = Auth.auth().currentUser?.uid {
            setObservers(uid: uid)
            
            loadCloudData() { data in
                guard let foodList = data?[DataListKeys.foodList.rawValue] as? NSDictionary else {
                    UserCookie.uc().loadingStatus = .loaded
                    return
                }
                if foodList.count == 0 {
                    UserCookie.uc().loadingStatus = .loaded
                }
            }
            
            KeyboardObserver.reset(.listhome)
        } else {
            KeyboardObserver.reset(.useraccess)
        }
        
        loadImages()
        _ = GTagLabeler.gtl()
        GCamera.initIVC()
        
        return true
    }

    // MARK: UISceneSession Lifecycle
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }

}

