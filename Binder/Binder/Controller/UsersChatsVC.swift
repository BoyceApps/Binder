//
//  UsersChatsVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/9/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import SwipeCellKit

class UserChatsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{
    
    var myChats = MY_CHATS{
        didSet{
            var newChatArray = [String]()
            if myChats.count > 0 {
                for key in myChats {
                    newChatArray.append(key.key)
                }
                chatArray = newChatArray
            }
            chatsTableView.reloadData()
        }
    }
    
    var chatArray: [String]?
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        DataService.instance.updateUserChats { (userChats) in
            self.myChats = userChats
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        chatsTableView.reloadData()
    }
    
    //TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyChatCell", for: indexPath) as! ChatTableViewCell
        
        let userUID = chatArray?[indexPath.row]
        
        DataService.instance.getName(forUid: userUID!, handler: { (name) in
            cell.chatLbl.text = name
        })
        
        if let imageFromCache = imageCache.object(forKey: userUID as AnyObject) as? UIImage{
            cell.chatPhoto.image = imageFromCache
        }else{
            let placePhotoRef = DataService.instance.REF_STORAGE_USERS.child(userUID!+"/profile_pic.jpg")
            
            placePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                if (error != nil) {
                    print("Error downloading profile image")
                }else {
                    
                    if (data != nil){
                        DispatchQueue.main.async {
                            let imageToCache = UIImage(data: data!)
                            
                            if userUID == self.chatArray![indexPath.row]{
                                cell.chatPhoto.image = imageToCache
                            }
                            imageCache.setObject(imageToCache!, forKey: userUID as AnyObject)
                        }
                    }
                }
            })
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            DataService.instance.removeUserPlace(placeID: self.chatArray![indexPath.row], handler: { (userChats) in
                self.myChats = userChats
            })
            self.chatArray?.remove(at: indexPath.row)
            self.chatsTableView.reloadData()
        }
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenChat" {
            let destinationVC = segue.destination as! ChatVC
            
            if let indexPath = chatsTableView.indexPathForSelectedRow {
                let userID = chatArray?[indexPath.row]
                let chatID = myChats[userID!] as! String
                destinationVC.chatID = chatID
                destinationVC.userUid = userID
            }
        }
    }
    
}
