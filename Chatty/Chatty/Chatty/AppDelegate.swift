//
//  AppDelegate.swift
//  Chatty
//
//  Created by Isabel  Lee on 28/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit

import Firebase
import GoogleSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {
    
    var window: UIWindow?
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any])
        -> Bool {
            print("\n\n\n\n\n\n\nDeeplink1")
            let dynamicLink = FIRDynamicLinks.dynamicLinks()?.dynamicLink(fromCustomSchemeURL: url)
            if dynamicLink != nil {
                self.handleIcomingLink(dynamicLink!)
                print("Deep link of first launch or old device")
                return true
            }
            
            return GIDSignIn.sharedInstance().handle(url,
                                                     sourceApplication:options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
                                                     annotation: [:])
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication,
                     continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let dynamicLinks = FIRDynamicLinks.dynamicLinks() else {
            return false
        }
        
        print("\n\n\n\n\n\n\nDeeplink2")
        let handled = dynamicLinks.handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
            if let dynamiclink = dynamiclink, let _ = dynamiclink.url {
                self.handleIcomingLink(dynamiclink)
            } else {
                print("Error: \(String(describing: error?.localizedDescription))")
            }
        }
        return handled
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error {
            print("Error \(error)")
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print("Error \(error)")
                return
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FIRApp.configure()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        return true
    }
    
    func handleIcomingLink(_ dynamicLink: FIRDynamicLink) {
        print("DynamicLink: \(dynamicLink)")
    
        guard let pathComponents = dynamicLink.url?.pathComponents  else { return }
        for component in pathComponents {
            print("\t>> component: \(component)")
        }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let messageViewController = storyboard.instantiateViewController(withIdentifier: "messageViewController") as! MessagesViewController
        let signInViewController = storyboard.instantiateViewController(withIdentifier: "signInViewController") as! SignInViewController
        signInViewController.groupInvitation = pathComponents.last
        window?.rootViewController = signInViewController
        print("presenting view controller")
        messageViewController.groupId = pathComponents.last!
        
    }
}

