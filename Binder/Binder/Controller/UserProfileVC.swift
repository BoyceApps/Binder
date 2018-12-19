//
//  UserProfileVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/10/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class UserProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    var userUid: String?{
        didSet{
            print("getting user dict")
            DataService.instance.getUserData(forUserUid: userUid!) { (userData) in
                self.nameLbl.text = userData["name"] as? String
                self.titleLbl.text = userData["name"] as? String ?? "Binder"
                self.bioLbl.text = userData["bio"] as? String ?? ""
                self.userPlaces = userData["UserPlaces"] as? Dictionary<String, Any>
                self.emailLbl.text = userData["email"] as? String
            }
        }
    }
    
    var userPlaces: Dictionary<String, Any>?{
        didSet{
            var userPlaceArray = [String]()
            for place in userPlaces! {
                userPlaceArray.append(place.key)
            }
            placeArray = userPlaceArray
        }
    }
    
    var placeArray: [String]?{
        didSet{
            placeCV.reloadData()
        }
    }
    
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var placeCV: UICollectionView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bioLbl: UILabel!
    @IBOutlet weak var userPhoto: UIImageView!
    
    override func viewWillAppear(_ animated: Bool) {
        
        if userPlaces != nil {
            var userPlaceArray = [String]()
            for key in userPlaces! {
                userPlaceArray.append(key.key)
            }
            placeArray = userPlaceArray
        }
        
        if let imageFromCache = imageCache.object(forKey: userUid as AnyObject) as? UIImage{
            self.userPhoto.image = imageFromCache
            self.userPhoto.layer.cornerRadius = (self.userPhoto.frame.size.height/2) //round the corner of photo
            self.userPhoto.layer.masksToBounds = true
            self.userPhoto.layer.borderWidth = 2
            self.userPhoto.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            self.userPhoto.contentMode = .scaleAspectFit
            self.userPhoto.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            self.userPhoto.layer.shadowOpacity = 0.5
            self.userPhoto.layer.shadowRadius = 0.5
            self.userPhoto.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
        }else{
            print("getting user photo")
            let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child(userUid!+"/profile_pic.jpg")
            
            profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                if (error != nil) {
                    print("Error downloading profile image")
                }else {
                    if (data != nil){
                        self.userPhoto.image = UIImage(data: data!)
                        self.userPhoto.layer.cornerRadius = (self.userPhoto.frame.size.height/2) //round the corner of photo
                        self.userPhoto.layer.masksToBounds = true
                        self.userPhoto.layer.borderWidth = 2
                        self.userPhoto.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                        self.userPhoto.contentMode = .scaleAspectFit
                        self.userPhoto.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                        self.userPhoto.layer.shadowOpacity = 0.5
                        self.userPhoto.layer.shadowRadius = 0.5
                        self.userPhoto.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
                    }
                }
            })
        }
        placeCV.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placeCV.delegate = self
        placeCV.dataSource = self
        bioLbl.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        bioLbl.layer.borderWidth = 1
        bioLbl.layer.cornerRadius = 6
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPlacePic", for: indexPath) as! UserPlaceCollectionViewCell
        
        let placeID = placeArray![indexPath.row]
        
        if let imageFromCache = imageCache.object(forKey: placeID as AnyObject) as? UIImage{
            cell.placePhoto.image = imageFromCache
            
        }else{
            
            let placePhotoRef = DataService.instance.REF_STORAGE_PLACES.child(placeID+"/placePic.jpg")
            placePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                if (error != nil) {
                    print("Error downloading place image")
                }else {
                    if (data != nil){
                        DispatchQueue.main.async {
                            let imageToCache = UIImage(data: data!)
                            if placeID == self.placeArray![indexPath.row]{
                                cell.placePhoto.image = imageToCache
                            }
                            imageCache.setObject(imageToCache!, forKey: placeID as AnyObject)
                            self.placeCV.reloadData()
                        }
                    }
                }
            })
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "PlaceChatShortcut", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceChatShortcut" {
            print("going to place chat")
            let destinationVC = segue.destination as! PlaceChatVC
            
            if let indexPath = placeCV.indexPathsForSelectedItems?.first {
                let placeID = placeArray?[indexPath.row]
                destinationVC.placeID = placeID
                var place = userPlaces![placeID!] as! Dictionary<String, Any>
                destinationVC.name = place.removeValue(forKey: "name") as? String
            }
        }else{
            if segue.identifier == "NewChat" {
                print("going to place chat")
                let destinationVC = segue.destination as! ChatVC
        
                let senderFirst8 = userUid?.prefix(8)
                let myFirst8 = currentUser?.uid.prefix(8)
                
                if myFirst8! > senderFirst8! {
                    destinationVC.userUid = userUid
                    let chatID = myFirst8?.appending(senderFirst8!)
                    destinationVC.chatID = chatID
                    DataService.instance.addNewChat(senderUid: (currentUser?.uid)!, recieverUid: userUid!, chatID: chatID!)
                }else{
                    destinationVC.userUid = userUid
                    let chatID = senderFirst8?.appending(myFirst8!)
                    destinationVC.chatID = chatID
                    DataService.instance.addNewChat(senderUid: (currentUser?.uid)!, recieverUid: userUid!, chatID: chatID!)
                }
            }
        }
    }
    
    @IBAction func chatBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "NewChat", sender: self)
    }
    
    @IBAction func backBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
