//
//  GroupsViewController.swift
//  Chatty
//
//  Created by Isabel  Lee on 28/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.

//  MARK: - Attribution
//  http://stackoverflow.com/questions/36210424/retrieve-randomly-generated-child-id-from-firebase
//  http://stackoverflow.com/questions/24334653/colorwithalphacomponent-example-in-swift

import UIKit
import Firebase

class GroupsViewController: UIViewController {
    
    
    //MARK: Constants
    let groupRef = FIRDatabase.database().reference(withPath: "groups")
    let userRef = FIRDatabase.database().reference(withPath: "users/\((FIRAuth.auth()?.currentUser?.uid)!)")
    let groupListRef = FIRDatabase.database().reference(withPath: "users/\((FIRAuth.auth()?.currentUser?.uid)!)/groupList")
    let defaults = UserDefaults.standard
    
    //MARK: Variables
    var groupList: [Group] = []
    var segueGroupId: String?
    var segueGroupName: String?
    
    @IBOutlet weak var tableView: UITableView!

    @IBAction func logOutTapped(_ sender: UIButton) {
        let firebaseAuth = FIRAuth.auth()
        do {
            try firebaseAuth?.signOut()
            dismiss(animated: true, completion: nil)
        } catch let signOutError as NSError {
            print ("Error signing out: \(signOutError.localizedDescription)")
        }
    }
    
    @IBAction func addNewGroup(_ sender: UIButton) {
        let alertController = UIAlertController(title: "Group Name", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { Void in
            let groupNameTextfield = alertController.textFields![0] as UITextField
            let groupName = groupNameTextfield.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).capitalized
            print("New Group: \(String(describing: groupName))")
            if groupName != "" {
                //Getting the new group's auto id
                let newGroupRef = self.groupRef.childByAutoId()
                newGroupRef.setValue(["name":groupName!])
                newGroupRef.child("userList").childByAutoId().setValue((FIRAuth.auth()?.currentUser?.uid)!)
                let newGroupId = newGroupRef.key
                print(newGroupId)
                //Adding the new group's auto id to the user's group list
                self.groupListRef.childByAutoId().setValue(newGroupId)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: { Void in
        })
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = ""
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func unwindToGroupVC(sender: UIStoryboardSegue) {
        print("unwinded to group vc")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "groupCell")
        
        groupListRef.observe(.childAdded, with: { snapshot in
            let newGroupId = "\(snapshot.value!)"
            print(newGroupId)
            //print(snapshot.value)
            self.groupRef.child(newGroupId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let groupInfo = snapshot.value as! [String:Any]? {
                    let newGroup = Group(groupInfo: groupInfo, groupId: newGroupId)
                    self.groupList.append(newGroup)
                    dump(self.groupList)
                    self.tableView.reloadData()
                }
            })
        })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let segueGroupId = defaults.object(forKey: "segueGroupId") as! String?{
            self.groupRef.child(segueGroupId).observeSingleEvent(of: .value, with: { (snapshot) in
                if let groupInfo = snapshot.value as! [String:Any]? {
                    self.segueGroupId = segueGroupId
                    self.segueGroupName = groupInfo["name"] as? String
                    self.defaults.removeObject(forKey: "segueGroupId")
                    self.performSegue(withIdentifier: "firstInviteSegue", sender: self)
                }
            })
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chatRoomSegue" {
            let vc = segue.destination as! MessagesViewController
            let selectedRow = self.tableView.indexPathForSelectedRow!.row
            vc.groupName = groupList[selectedRow].groupName
            vc.groupId = groupList[selectedRow].groupId
        }
        
        if segue.identifier == "firstInviteSegue" {
            let vc = segue.destination as! MessagesViewController
            vc.groupName = self.segueGroupName!
            vc.groupId = self.segueGroupId!
        }
    }
    
    deinit {
        groupRef.removeAllObservers()
    }
}

extension GroupsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath)
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.4)
        cell.selectedBackgroundView = view
        cell.textLabel!.text = groupList[indexPath.row].groupName
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.backgroundColor = UIColor.clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "chatRoomSegue", sender: self)
    }
}
