//
//  BinderVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/27/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase
import FirebaseCore
import FirebaseAuth

class BinderVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        DataService.instance.updateUserPlaces()

    }
    
    @IBAction func logOutButtonPressed(_ sender: Any) {
        do{
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
            self.performSegue(withIdentifier: "UnwindToInitialVC", sender: self)
        }catch{
            print("Error signing out \(error)")
        }
        print("User logged out")
        
    }
    

}
