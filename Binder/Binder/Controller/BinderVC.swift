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
        
        if currentUser?.uid != nil{
            DataService.instance.getUserPhoto(userUid: (currentUser?.uid)!)
            DataService.instance.getMyPlacePhotos()
        }
        //DataService.instance.updateUserPlaces()
        
    }    
    
}
