//
//  ViewController.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/27/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import FacebookCore
import FacebookLogin
import FirebaseCore
import FirebaseDatabase
import FirebaseAuth
import FirebaseStorage

class InitialVC: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            //Go to Binder Controller with user info
            if currentUser != nil{
            self.performSegue(withIdentifier: "LoggedIn", sender: self)
            }
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }


}

