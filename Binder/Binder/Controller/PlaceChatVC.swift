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

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var sendMessageView: UIView!
    @IBOutlet weak var viewTitle: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendMessageView.bindToKeyboard()
        viewTitle.text = name
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTextView.delegate = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        
        self.view.addGestureRecognizer(tapGesture)
        
        configureTableView()
        
        retrieveMessages()
        
        messageTableView.separatorStyle = .none
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath) as! MessageTableViewCell
        
        cell.messageLbl.text = messageArray[indexPath.row].content
        
        cell.date.text = messageArray[indexPath.row].date
        
        let senderUid = messageArray[indexPath.row].senderUid
        
        var gotPhoto = false
        
        if let imageFromCache = imageCache.object(forKey: senderUid as AnyObject) as? UIImage{
            cell.userPhoto.image = imageFromCache
            gotPhoto = true
        }
        
        if senderUid == Auth.auth().currentUser?.uid as String? {
            
            if !gotPhoto{
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                
                profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                    if (error != nil) {
                        print("Error downloading message image")
                    }else {
                        if (data != nil){
                            let imageToCache = UIImage(data: data!)
                            cell.userPhoto.image = imageToCache
                            imageCache.setObject(imageToCache!, forKey: senderUid as AnyObject)
                            
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
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child(senderUid+"/profile_pic.jpg")
                
                profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                    if (error != nil) {
                        print("Error downloading message image")
                    }else {
                        if (data != nil){
                            let imageToCache = UIImage(data: data!)
                            cell.userPhoto.image = imageToCache
                            imageCache.setObject(imageToCache!, forKey: senderUid as AnyObject)
                        }
                    }
                })
            }
            
            //Set background to light blue if message is from another user.
            cell.messageBackground.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            cell.rightMargin.constant = 60
            cell.leftMargin.constant = 10
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ToUserProfile", sender: self)
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
        self.sendMessageView.frame.origin.y += 34
        UIView.animate(withDuration: 0.2) {
            if self.messageTextView.text == "Send A Message!"{
                self.messageTextView.text = ""
                self.messageTextView.textColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            }
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.sendMessageView.frame.origin.y -= 34
        UIView.animate(withDuration: 0.2) {
            if self.messageTextView.text == ""{
                self.messageTextView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                self.messageTextView.text = "Send A Message!"
            }
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
        
        let messageDictionary = ["Sender": Auth.auth().currentUser?.uid,
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
            self.messageTextView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
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
            
            let message = Message(content: text, senderUid: sender, date: date)
            
            self.messageArray.append(message)
            self.configureTableView()
            self.messageTableView.reloadData()
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ToUserProfile" {
            let destinationVC = segue.destination as! UserProfileVC
            
            if let indexPath = messageTableView.indexPathForSelectedRow {
                destinationVC.userUid = messageArray[indexPath.row].senderUid
            }
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
        let deltaY = endFrame.origin.y - beginningFrame.origin.y
        
        UIView.animateKeyframes(withDuration: duration, delay: 0.0, options: UIView.KeyframeAnimationOptions(rawValue: curve), animations: {
            self.frame.origin.y += deltaY
        }, completion: nil)
    }
}
