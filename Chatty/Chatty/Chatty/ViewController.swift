//
//  ViewController.swift
//  Chatty
//
//  Created by Isabel  Lee on 28/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn

@objc(SignInViewController)
class SignInViewController: UIViewController, GIDSignInUIDelegate {
    @IBOutlet weak var signInButton: GIDSignInButton!
    var handle: FIRAuthStateDidChangeListenerHandle?
    var groupInvitation: String?
    let defaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("group invitation: \(String(describing: groupInvitation))")
        let ref = FIRDatabase.database().reference(withPath: "users")
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            if user != nil {
                //MeasurementHelper.sendLoginEvent()
                var avatarURL = ""
                if let photoURL = FIRAuth.auth()?.currentUser?.photoURL {
                   avatarURL = photoURL.absoluteString
                }
                ref.child("\((FIRAuth.auth()?.currentUser?.uid)!)/name").setValue((FIRAuth.auth()?.currentUser?.displayName)!)
                ref.child("\((FIRAuth.auth()?.currentUser?.uid)!)/avatar").setValue(avatarURL)
                
                if let newGroup = self.groupInvitation {
                    print("adding user to new group")
                    ref.child("\((FIRAuth.auth()?.currentUser?.uid)!)/groupList").childByAutoId().setValue(newGroup)
                    let groupListRef = FIRDatabase.database().reference(withPath: "groups/\(newGroup)/userList")
                    groupListRef.childByAutoId().setValue((FIRAuth.auth()?.currentUser?.uid)!)
                    self.defaults.set(newGroup, forKey: "segueGroupId")
                    self.groupInvitation = nil
                }
                
                self.performSegue(withIdentifier: "groupVCSegue", sender: nil)
            }
        }
    }
    
    deinit {
        if let handle = handle {
            FIRAuth.auth()?.removeStateDidChangeListener(handle)
        }
    }
}
