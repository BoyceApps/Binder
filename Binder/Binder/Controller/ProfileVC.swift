//
//  ProfileVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/29/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit

class ProfileVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate  {
    
    var myPlaces: Dictionary<String, Any>?{
        didSet{
            var userPlaceArray = [String]()
            
            for key in myPlaces! {
                userPlaceArray.append(key.key)
            }
            placeArray = []
            placeArray = userPlaceArray
            
        }
    }
    var placeArray: [String]?{
        didSet{
            self.placeCV.reloadData()
        }
    }
    
    var userBio = ""
    
    @IBOutlet weak var saveCancelView: UIStackView!
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var placeCV: UICollectionView!
    @IBOutlet weak var bioTxtView: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
        
        if currentUser?.uid != nil{
            DataService.instance.getUserData(forUserUid: (currentUser?.uid)!) { (userData) in
                self.nameLbl.text = userData["name"] as? String ?? ""
                self.userBio = userData["bio"] as? String ?? ""
                self.myPlaces = (userData["UserPlaces"] as? Dictionary<String, Any>) ?? Dictionary<String, Any>()
                self.emailLbl.text = userData["email"] as? String
                if self.userBio != ""{
                    self.bioTxtView.text = self.userBio
                    self.bioTxtView.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                }
                else{
                    self.bioTxtView.text = "Enter something about yourself. Such as your favorite drink, favorite bar.. etc."
                    self.bioTxtView.textColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
                }
            }
            if let imageFromCache = imageCache.object(forKey: currentUser?.uid as AnyObject) as? UIImage{
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
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                
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
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveCancelView.bindToKeyboard()
        saveCancelView.isHidden = true
        bioTxtView.delegate = self
        bioTxtView.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        bioTxtView.layer.borderWidth = 1
        bioTxtView.layer.cornerRadius = 6
        //        let tapGesture = UITapGestureRecognizer(target: self, action: #selector (tableViewTapped))
        //
        //        self.view.addGestureRecognizer(tapGesture)
        placeCV.delegate = self
        placeCV.dataSource = self
        myPlaces = MY_PLACES
        placeCV.reloadData()
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return placeArray?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserPlacePic", for: indexPath) as! PlaceCollectionViewCell
        
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
    
    
    
    //MARK: - TextField Delegate Methods
    
    //    @objc func tableViewTapped() {
    //        bioTxtView.endEditing(true)
    //    }
    
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.saveCancelView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            if self.bioTxtView.text == "Enter something about yourself. Such as your favorite drink, favorite bar.. etc."{
                self.bioTxtView.text = ""
                self.bioTxtView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.saveCancelView.isHidden = true
        UIView.animate(withDuration: 0.2) {
            if self.bioTxtView.text == ""{
                self.bioTxtView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                self.bioTxtView.text = "Enter something about yourself. Such as your favorite drink, favorite bar.. etc."
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlaceChatShortcut" {
            print("going to place chat")
            let destinationVC = segue.destination as! PlaceChatVC
            
            if let indexPath = placeCV.indexPathsForSelectedItems?.first {
                let placeID = placeArray?[indexPath.row]
                destinationVC.placeID = placeID
                var place = myPlaces![placeID!] as! Dictionary<String, Any>
                destinationVC.name = place.removeValue(forKey: "name") as? String
            }
        }
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        if bioTxtView.text != nil && bioTxtView.text != "Enter something about yourself. Such as your favorite drink, favorite bar.. etc." {
            userBio = bioTxtView.text
            DataService.instance.REF_USERS.child((currentUser?.uid)!).updateChildValues(["bio":userBio])
            self.saveCancelView.isHidden = true
            UIView.animate(withDuration: 0.2) {
                self.bioTxtView.endEditing(true)
                self.bioTxtView.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
        }
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        self.saveCancelView.isHidden = true
        bioTxtView.endEditing(true)
        UIView.animate(withDuration: 0.2) {
            if self.bioTxtView.text == ""{
                self.bioTxtView.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
                self.bioTxtView.text = "Enter more about yourself. Such as your favorite drink, favorite bar.. ect."
            }
        }
    }
    
    @IBAction func LogOutButtonPressed(_ sender: Any) {
        
        do {
            
            try Auth.auth().signOut()
            
            FBSDKAccessToken.setCurrent(nil)
            currentUser = nil
            
            performSegue(withIdentifier: "UnwindToInitialVC", sender: self)
            
        }
        catch {
            print("error: there was a problem logging out")
        }
        
    }
    
    
}
