//
//  MessagesViewController.swift
//  Chatty
//
//  Created by Isabel  Lee on 29/04/2017.
//  Copyright © 2017 isabeljlee. All rights reserved.

//  MARK: - Attribution
//  http://stackoverflow.com/questions/1126726/how-to-make-a-uitextfield-move-up-when-keyboard-is-present
//  http://stackoverflow.com/questions/11989306/get-the-frame-of-the-keyboard-dynamically
//  http://stackoverflow.com/questions/2267993/uitableview-how-to-disable-selection-for-some-rows-but-not-others
//  http://stackoverflow.com/questions/4414221/uiimage-in-a-circle

import UIKit
import Firebase
import Photos

class MessagesViewController: UIViewController, FIRInviteDelegate {

    @IBOutlet weak var textField: UITextField!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    var groupRef = FIRDatabase.database().reference(withPath: "groups")
    var messageRef = FIRDatabase.database().reference(withPath: "messages")
    var userRef = FIRDatabase.database().reference(withPath: "users")
    var storageRef: FIRStorageReference!
    var onlineRef: FIRDatabaseReference!
    var currentUserOnlineRef: FIRDatabaseReference!
    let userId = (FIRAuth.auth()?.currentUser?.uid)!
    var groupName = ""
    var groupId = ""
    var keyboardHeight: CGFloat = 258.0
    var message = ""
    var messageList:[Message] = []
    var userList:[String:User] = [:]
    var viewCenter: CGFloat!
    
    @IBAction func addPhoto(_ sender: UIButton) {
        launchPhotoPicker()
    }
    

    @IBAction func sendButtonTapped(_ sender: UIButton) {
        textField.text = ""
        postMessage(message: message)
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        print("back button tapped")
        print("Being presented? \(self.isBeingPresented)")
        if self.isBeingPresented {
            print("dismissing the view")
            self.dismiss(animated: true, completion: nil)
        } else {
            self.performSegue(withIdentifier: "unwindToGroupVCSegue", sender: self)
        }
    }
    
    @IBAction func inviteFriend(_ sender: UIButton) {
        let dynamicLink = "https://nwaf4.app.goo.gl/?link=http://www.isabeljlee.com/chattychat/group/\(groupId)&isi=1225060233&ibi=com.isabeljlee.Chatty-chat"
        let msg = "You are invited to a group: " + dynamicLink
        let shareSheet = UIActivityViewController(activityItems: [ msg ],
                                                  applicationActivities: nil)
        shareSheet.popoverPresentationController?.sourceView = self.view
        self.present(shareSheet, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewCenter = self.view.center.y

        //Observing the keyboard's height so we can move the textview accordingly
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardDidShow(_:)), name: .UIKeyboardWillShow, object: nil)
        textField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        groupNameLabel.text = "\(groupName)(1)"
        groupRef = FIRDatabase.database().reference(withPath: "groups/\(groupId)")
        messageRef = FIRDatabase.database().reference(withPath: "messages/\(groupId)")
        storageRef = FIRStorage.storage().reference()
        onlineRef = groupRef.child("online")
        
        //Adding the current user's id to the online list for this group
        currentUserOnlineRef = onlineRef.childByAutoId()
        currentUserOnlineRef.setValue(userId)
        
        
        //Observe new messages added to the group
        messageRef.observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            let messageInfo = snapshot.value as! [String:String]
            strongSelf.processMessage(messageInfo: messageInfo, completion: { (message) in
                DispatchQueue.main.async {
                    strongSelf.messageList.append(message)
                    dump(strongSelf.messageList)
                    strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.messageList.count-1, section: 0)], with: .automatic)
                }
            })
        })
        
        //Observing if a new member joins the group
        //Using the user id of the new user, query the database for name/avatar image of the new user, 
        //and add the new user to UserList so we can display his/her name, avatar properly in the 
        //messages
        
        groupRef.child("userList").observe(.childAdded, with: { [weak self] (snapshot) -> Void in
            guard let strongSelf = self else { return }
            //print("\(snapshot.value)")
            let newUserId = snapshot.value as! String
            strongSelf.userRef.child(newUserId).observeSingleEvent(of: .value, with: { (snapshot) in
                //print("\(snapshot.value)")
                if let userInfo = snapshot.value as! [String:Any]?{
                    print(userInfo["name"] ?? "none")
                    let newUser = User(name: userInfo["name"]! as! String)
                    if let photoURL = userInfo["avatar"], let URL = URL(string: photoURL as! String),
                        let data = try? Data(contentsOf: URL) {
                        newUser.avatar = UIImage(data: data)
                    }
                    strongSelf.userList[newUserId] = newUser
                    dump(strongSelf.userList)
                    strongSelf.tableView.reloadData()
                }
            })
        })
        
        //Monitor the number of users currently online
        onlineRef.observe(.value, with: { snapshot in
            if snapshot.exists() {
                print("\n\n\n\n\n\n\n\n\n\nNumber of users online ======================== ")
                print(snapshot.childrenCount.description)
                self.groupNameLabel.text = "\(self.groupName)(\(snapshot.childrenCount.description))"
            } else {
                print("No one is online")
            }
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        currentUserOnlineRef.removeValue()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        messageRef.removeAllObservers()
        groupRef.removeAllObservers()
        userRef.removeAllObservers()
        //onlineRef.removeAllObservers()
    }
    
    func processMessage(messageInfo: [String:String], completion: @escaping ((Message)->Void)){
        let senderId = messageInfo["user"]!
        var messageType:MessageType = .text
        var message: String?
        var image: UIImage?
        if let text = messageInfo["message"] {
            message = text
            completion(Message(sender: senderId, message: message, image: image, messageType: messageType))
        }
        if let url = messageInfo["imageUrl"] {
            print("attempting to download image")
            messageType = .image
            if url.hasPrefix("gs://") {
                FIRStorage.storage().reference(forURL: url).data(withMaxSize: INT64_MAX) {(data, error) in
                    if let error = error {
                        print("Error downloading: \(error)")
                        return
                    }
                    print("Image was downlaoded")
                    image = UIImage.init(data: data!)
                    completion(Message(sender: senderId, message: message, image: image, messageType: messageType))
                }
            } else if let URL = URL(string: url), let data = try? Data(contentsOf: URL) {
                image = UIImage.init(data: data)
                completion(Message(sender: senderId, message: message, image: image, messageType: messageType))
            }
        }
    }
}

extension MessagesViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            print("We got an image")
            let imageData = UIImageJPEGRepresentation(pickedImage, 0.4)
            let imagePath = "\(userId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            self.storageRef.child(imagePath)
                .put(imageData!, metadata: metadata) { [weak self] (metadata, error) in
                    if let error = error {
                        print("Error uploading: \(error)")
                        return
                    }
                    guard let strongSelf = self else { return }
                    strongSelf.postImage(imageUrl: strongSelf.storageRef.child((metadata?.path)!).description)
            }
        } else {
            print("Error adding image")
        }
        dismiss(animated: true, completion: nil)
    }
    
    func postImage(imageUrl: String) {
        self.messageRef.childByAutoId().setValue(["imageUrl":imageUrl, "user":userId])
    }
    
    func pleaseGrantAccessAlert(){
        let alert = UIAlertController(title: "Please grant access", message: "Chatty needs to access your photo library! Go to settings > Chatty to grant permission!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func launchPhotoPicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        
        if self.checkPhotoLibraryAuthorization(){
            print("photo library access granted")
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self.present(imagePicker, animated: true){
                
            }
        } else {
            print("photo library access not granted")
            self.pleaseGrantAccessAlert()
        }
    }
    
    func checkPhotoLibraryAuthorization() -> Bool {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .denied: return false
        case .authorized: return true
        case .restricted: return false
        case .notDetermined:
            var requestFinish = false
            var status = false
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if (newStatus == PHAuthorizationStatus.authorized) {
                    print("Granted access to photo Library")
                    requestFinish = true
                    status = true
                }
                else {
                    print("Denied access to photo Library")
                    requestFinish = true
                }
            })
            
            while (requestFinish == false) {
                
            }
            return status
        }
    }
    
    private func inviteFinished(withInvitations invitationIds: [Any], error: Error?) {
        if let error = error {
            print("Failed: \(error.localizedDescription)")
        } else {
            print("Invitations sent")
        }
    }
}

extension MessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageList.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let senderId = messageList[row].senderId
        if messageList[row].messageType == .text {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessagesTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.nameLabel.text = userList[senderId]?.name
            cell.messageLabel.text = messageList[row].message
            cell.messageLabel.backgroundColor = UIColor.clear
            cell.messageLabel.sizeToFit()
            cell.backgroundColor = UIColor.clear
            cell.avatarImage.image = userList[senderId]?.avatar
            cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.width/2
            cell.avatarImage.layer.masksToBounds = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageMessageCell", for: indexPath) as! ImageMessageTableViewCell
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.backgroundColor = UIColor.clear
            cell.messageImage.image = messageList[row].image
            cell.messageImage.layer.cornerRadius = 30
            cell.messageImage.layer.masksToBounds = true
            cell.avatarImage.image = userList[senderId]?.avatar
            cell.avatarImage.layer.cornerRadius = cell.avatarImage.frame.width/2
            cell.avatarImage.layer.masksToBounds = true
            cell.nameLabel.text = userList[senderId]?.name
            return cell
        }

        //cell.avatarImage.layer.borderColor = UIColor.green.cgColor
        //cell.avatarImage.layer.borderWidth = 1.0
    }
}

extension MessagesViewController: UITextFieldDelegate {

    func keyboardDidShow(_ notification: NSNotification) {
        let keyboardSize:CGSize = (notification.userInfo![UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue.size
        
        let height = min(keyboardSize.height, keyboardSize.width)
        print("The height of the keyboard is: \(height)")
        keyboardHeight = height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //animateViewMoving(up: true)
        moveViewUp()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //animateViewMoving(up: false)
        moveViewDown()
        message = textField.text!
        print(message)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func animateViewMoving (up:Bool){
        print("The height of the keyboard is \(keyboardHeight)")
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -keyboardHeight : keyboardHeight)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0,  dy: movement)
        UIView.commitAnimations()
    }
    
    func moveViewUp() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.center.y = self.view.center.y - self.keyboardHeight
        })
    }
    
    func moveViewDown() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.center.y = self.viewCenter
        })
    }
    
    func postMessage(message: String){
        self.messageRef.childByAutoId().setValue(["message":message, "user":userId])
        self.message = ""
    }
}
