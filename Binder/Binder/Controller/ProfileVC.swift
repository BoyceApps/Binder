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

class ProfileVC: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    
    @IBOutlet weak var profileTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileTableView.delegate = self
        profileTableView.dataSource = self

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if currentUser != nil {
            return 3
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for: indexPath) as! UserDataTableViewCell
        
        if indexPath.row == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileTableViewCell
            tableView.rowHeight = 200
    
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                
                profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                    if (error != nil) {
                        print("Error downloading profile image")
                    }else {
                        if (data != nil){
                            cell.profilePhoto.image = UIImage(data: data!)
//                            DataService.instance.REF_STORAGE_USERS.child(currentUser?.uid)
                        }
                    }
                    
                    
                })
            
            return cell
        }else if indexPath.row == 1{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for: indexPath) as! UserDataTableViewCell
            tableView.rowHeight = 80
            cell.keyLbl.text = "Display Name:"
            if let name = currentUser?.displayName {
                cell.valueLbl.text = name
            }
            else{
                    cell.valueLbl.text = "No Name Yet"
            }
            return cell
        }else if indexPath.row == 2{
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserDataCell", for: indexPath) as! UserDataTableViewCell
            tableView.rowHeight = 80
            cell.keyLbl.text = "Email:"
            if let email = currentUser?.email {
                cell.valueLbl.text = email
            }
            return cell
        }
        
        return cell
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
