//
//  LogInVC.swift
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


class LogInVC: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!

    //Facebook Login Button
    let loginButton = LoginButton(readPermissions: [.publicProfile, .email])
    let loginManager = FBSDKLoginManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = true
        activity.stopAnimating()
        //Facebook Login Button
        self.loginButton.center = view.center
        self.loginButton.delegate = self
        
        view.addSubview(loginButton)

    }
    
    //Facebook login completed
    func loginButtonDidCompleteLogin(_ loginButton: LoginButton, result: LoginResult) {
        switch result {
            //Check for errors
            case .failed(let error):
                print(error)
            //User cancelled log in
            case .cancelled:
                print("User cancelled login")
            //User logged into Facebook successfully
            case .success(let grantedPermissions, let declinedPermissions, let accessToken):
                print("User logged in on facebook with \(grantedPermissions) and \(declinedPermissions)")
                activity.isHidden = false
                activity.startAnimating()
                let credential = FacebookAuthProvider.credential(withAccessToken: (accessToken.authenticationToken))
                
                Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
                    //check for errors
                    if let error = error {
                        print(error)
                        return
                    }else{
                    //logged in firebase successful
                        if let user = authResult?.user {
                            print("Logged into Firebase")
                            currentUser = Auth.auth().currentUser
                            print(currentUser)
                            DataService.instance.updateUserPlaces()
                            if(true){
                                var profilePicData = Data()
                                // let storageRef = storage.reference().child("Users")
                                let profilePicRef = DataService.instance.REF_STORAGE_USERS.child(user.uid+"/profile_pic.jpg")
                                print(profilePicRef)
                                
                                var profilePic = FBSDKGraphRequest(graphPath: "me/picture", parameters: ["height": 300, "width" : 300, "redirect" : false], httpMethod: "GET")
                                
                                profilePic?.start(completionHandler: { (connection, result, error) in
                                    if (error == nil){
                                        
                                        let dictionary = result as? NSDictionary
                                        
                                        let data = dictionary?.object(forKey: "data") as? NSDictionary
                                        
                                        
                                        let urlPic = (data?.object(forKey: "url"))! as! String
                                        
                                        if let imageData = NSData(contentsOf: NSURL(string: urlPic)! as URL){
                                    
                                            
                                            let uploadTask = profilePicRef.putData(imageData as Data, metadata: nil){
                                                metadata, error in
                                                
                                                if (error == nil){
                                                    DataService.instance.REF_USERS.child((currentUser?.uid)!+"/photoRef").setValue(metadata?.path)
                                                } else {
                                                    print ("Error downloading image")
                                                }
                                            }
                                            profilePicData = imageData as Data
                                            //currentUser?.photoURL = profilePicData
                                        }
                                    }
                                })
                      
                                
                            }
                            
                            let userData = ["provider": user.providerID, "email": user.email, "name": user.displayName, "photoRef": "Users/"+(currentUser?.uid)!+"/profile_pic.jpg"]
                            
                            DataService.instance.createDBUser(uid: user.uid, userData: userData as Dictionary<String, Any>)
                            
                           
                            
                            currentUser = user
                            if currentUser != nil {
                                self.performSegue(withIdentifier: "UserLoggedIn", sender: self)
                            }
                        }
                    
                    }
                    
                    
                }
        }
        
    }
    
    
    
    //FaceBook Logout
    func loginButtonDidLogOut(_ loginButton: LoginButton) {
        do{
            try Auth.auth().signOut()
            FBSDKAccessToken.setCurrent(nil)
        }catch{
            print("Error signing out")
        }
        print("User logged out")
    }
    
    
    //Email Login Button pressed
    @IBAction func logInButtonPressed(_ sender: Any) {
        if emailTxtField.text != nil && passwordTxtField.text != nil {
            AuthService.instance.loginUser(withEmail: emailTxtField.text!, andPassword: passwordTxtField.text!, loginComplete: { (success, loginError) in
                if success {
                    print("User logged in")
                    self.performSegue(withIdentifier: "UserLoggedIn", sender: self)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                    self.emailTxtField.text = ""
                    self.passwordTxtField.text = ""
                }
            })
        }
        
    }
    
 

}
