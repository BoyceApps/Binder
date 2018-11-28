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
    
    override func viewDidLoad() {
        super.viewDidLoad()

     
    }

    @IBAction func logInButtonPressed(_ sender: Any) {
        //Register a new user on our Firebase database
        if emailTxtField.text != nil && passwordTxtField.text != nil {
            //try to sign in user
            AuthService.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!, loginComplete: { (success, loginError) in
                if success {
                    print("User logged in")
                } else {
                    print(String(describing: loginError?.localizedDescription))
                }
                //user isnt registered already, attempt to register user
                AuthService.instance.registerUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, userCreationComplete: { (success, registrationError) in
                    if success {
                        print("Successfully registered user")
                        AuthService.instance.loginUser(withEmail: self.emailTxtField.text!, andPassword: self.passwordTxtField.text!, loginComplete: { (success, nil) in
                            self.performSegue(withIdentifier: "NewUser", sender: self)
                        })
                    } else {
                        print(String(describing: registrationError?.localizedDescription))
                    }
                })
            })
        }
        
    }
    
}
