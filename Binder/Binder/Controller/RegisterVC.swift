//
//  RegisterVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/27/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import Firebase

class RegisterVC: UIViewController {

    @IBOutlet weak var displayNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordCheckTxtField: UITextField!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = true
        activity.stopAnimating()
     
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        activity.isHidden = false
        activity.startAnimating()
        //Register a new user on our Firebase database
        if emailTxtField.text != nil && passwordTxtField.text != nil && passwordCheckTxtField.text == passwordTxtField.text && displayNameTxtField.text != nil {
            //try to sign in user
            AuthService.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!, loginComplete: { (success, loginError) in
                if success {
                    print("User logged in")
                    self.performSegue(withIdentifier: "NewUser", sender: self)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                }
                //user isnt registered already, attempt to register user
                AuthService.instance.registerUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, userCreationComplete: { (success, registrationError) in
                    if success {
                        print("Successfully registered user")
                        AuthService.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, loginComplete: { (success, nil) in
                            if success {
                                let email = self.emailTxtField.text
                                let name = self.displayNameTxtField.text
                                let userData = ["provider": currentUser?.providerID, "email": email, "name": name, "photoRef": "Users/"+(currentUser?.uid)!+"/profile_pic.jpg"]
                                
                                DataService.instance.createDBUser(uid: (currentUser?.uid)!, userData: userData as Dictionary<String, Any>)
                                self.activity.stopAnimating()
                                self.activity.isHidden = true
                                self.performSegue(withIdentifier: "NewUser", sender: self)
                            }
                        })
                    } else {
                        print(String(describing: registrationError?.localizedDescription))
                        self.activity.stopAnimating()
                        self.activity.isHidden = true
                    }
                })
            })
        }
        
    }
    
}
