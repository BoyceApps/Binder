//
//  PlaceChatVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/2/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import Firebase

class PlaceChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate  {
    
    var messageArray : [Message] = [Message]()
    var placeID: String?
    var name: String?
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    
    
   
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendMessageView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendMessageView.bindToKeyboard()
        
        navigationItem.title = name
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        messageTableView.addGestureRecognizer(tapGesture)
        
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none

    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        
        cell.messageLbl.text = messageArray[indexPath.row].content
        
        cell.date.text = messageArray[indexPath.row].date
        
        let senderID = messageArray[indexPath.row].senderId
        
        var gotPhoto = false
        
        if let imageFromCache = imageCache.object(forKey: senderID as AnyObject) as? UIImage{
            cell.userPhoto.image = imageFromCache
            gotPhoto = true
        }
            
        if senderID == Auth.auth().currentUser?.email as String? {
            
            if !gotPhoto{
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                
                profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                    if (error != nil) {
                        print("Error downloading message image")
                    }else {
                        if (data != nil){
                            let imageToCache = UIImage(data: data!)
                            cell.userPhoto.image = imageToCache
                            self.imageCache.setObject(imageToCache!, forKey: senderID as AnyObject)
                            
                        }
                    }
                    
                })
            }
            
            //Set background to dark blue if message is from currentUser.
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            cell.leftMargin.constant = 60
            cell.rightMargin.constant = 10
    
        } else {
            if !gotPhoto{
                DataService.instance.getUid(forEmail: messageArray[indexPath.row].senderId) { (senderUid) in
                    let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child(senderUid+"/profile_pic.jpg")
                    
                    profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                        if (error != nil) {
                            print("Error downloading message image")
                        }else {
                            if (data != nil){
                                let imageToCache = UIImage(data: data!)
                                cell.userPhoto.image = imageToCache
                                self.imageCache.setObject(imageToCache!, forKey: senderID as AnyObject)
                            }
                        }
                    })
                }
            }
            
            //Set background to light blue if message is from another user.
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            cell.rightMargin.constant = 60
            cell.leftMargin.constant = 10
        }
        
        return cell
    }
    
    
    
    //TableView Delegate Mathods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    @objc func tableViewTapped() {
        messageTextView.endEditing(true)
    }
    
    
    //TODO: Declare configureTableView here:
    
    func configureTableView() {
        messageTableView.rowHeight = UITableView.automaticDimension
        messageTableView.estimatedRowHeight = 180.0
        
        
    }
    
    //MARK: - TextField Delegate Methods
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        UIView.animate(withDuration: 0.2) {
            if self.messageTextView.text == "Send A Message!"{
                self.messageTextView.text = ""
            }
            self.view.layoutIfNeeded()
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        UIView.animate(withDuration: 0.2) {
            //self.heightConstraint.constant = 50
            if self.messageTextView.text == ""{
                self.messageTextView.text = "Send A Message!"
            }
            self.sendMessageView.frame.origin.y = self.view.frame.height - 84
            self.view.layoutIfNeeded()
        }
    }
    
    ///////////////////////////////////////////
    
    
    //MARK: - Send & Recieve Messages from Firebase
    
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        
        messageTextView.endEditing(true)
        messageTextView.isEditable = false
        sendButton.isEnabled = false
        
        let messagesDB = DataService.instance.REF_PLACECHATS.child(placeID!)
        
        let date = Date()
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        let dateString = dateFormatter.string(from: date)
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.email,
                                 "MessageBody": messageTextView.text!, "Date": dateString]
        
        messagesDB.childByAutoId().setValue(messageDictionary) {
            (error, reference) in
            
            if error != nil {
                print(error!)
            }
            else {
                print("Message saved successfully!")
            }
            
            self.messageTextView.isEditable = true
            self.sendButton.isEnabled = true
            self.messageTextView.text = "Send A Message!"
        }
        
    }
    
    
    func retrieveMessages() {
        
        let messageDB = DataService.instance.REF_PLACECHATS.child(placeID!)
        
        messageDB.observe(.childAdded) { (snapshot) in
            
            let snapshotValue = snapshot.value as! Dictionary<String,String>
            let text = snapshotValue["MessageBody"]!
            let sender = snapshotValue["Sender"]!
            let date = snapshotValue["Date"]!
            
            let message = Message(content: text, senderId: sender, date: date)
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

extension UIView {
    
    func bindToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(_ notification: NSNotification) {
        let duration = notification.userInfo![UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        let curve = notification.userInfo![UIResponder.keyboardAnimationCurveUserInfoKey] as! UInt
        let beginningFrame = (notification.userInfo![UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let endFrame = (notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let deltaY = endFrame.origin.y - beginningFrame.origin.y + 34
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}
