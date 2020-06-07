//
//  AppDelegate.swift
//  Grumble
//
//  Created by Allen Chang on 3/20/20.
//  Copyright © 2020 Cylumn, Inc. All rights reserved.
//

import UIKit
import SwiftUI
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
            
            //First SignIn Google
            if !hasEmailProvider {
                let linkToken: String = randomString(length: 10)
                UserAccessCookie.uac().setLinkToken(linkToken)
                writeLocalData(DataListKeys.linkToken, linkToken)
                writeCloudData(DataListKeys.linkToken, linkToken)
                createLinkedAccount(pass: linkToken)
            }
            
            onLogin(requireCloud: true)
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
        UserAccessCookie.uac().setLoggedIn(Auth.auth().currentUser)
        
        if let _ = Auth.auth().currentUser?.uid {
            onLogin(requireCloud: false)
        } else {
            KeyboardObserver.reset(.useraccess)
        }
        
        loadImages()
        _ = GTagLabeler.gtl()
        _ = ImageLibrary.library()
        _ = GCamera.camera()
        
        var imageIDs: [String] = []
        var tagList: [[GrubTag: Double]] = []
        for (_, grub) in UserCookie.uc().foodList() {
            imageIDs.append(grub.img)
            tagList.append(grub.tags)
        }
        print("requesting preferences for: ")
        print(imageIDs)
        print(tagList)
        requestPreferences(imageIDs: imageIDs, tagList: tagList) { preferences in
            print("found preferences!")
            print(preferences)
        }
        
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

