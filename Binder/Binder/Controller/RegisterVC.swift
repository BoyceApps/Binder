//
//  RegisterVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/27/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import Firebase
import Photos

class RegisterVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var displayNameTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet weak var passwordCheckTxtField: UITextField!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var photoBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.isHidden = true
        activity.stopAnimating()
        photoBtn.layer.cornerRadius = (photoBtn.frame.size.height/2) //round the corner of photo
        photoBtn.layer.masksToBounds = true
        photoBtn.layer.borderWidth = 2
        photoBtn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        photoBtn.contentMode = .scaleAspectFit
        photoBtn.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        photoBtn.layer.shadowOpacity = 0.5
        photoBtn.layer.shadowRadius = 0.5
        photoBtn.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
        checkPermission()
        
        
    }
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    @IBAction func photoBtnPressed(_ sender: UIButton) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else{
            presentPhotoPicker(sourceType: .photoLibrary)
            return
        }
        
        let photoSourcePicker = UIAlertController()
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .camera)
        }
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.presentPhotoPicker(sourceType: .photoLibrary)
        }
        
        photoSourcePicker.addAction(takePhotoAction)
        photoSourcePicker.addAction(choosePhotoAction)
        photoSourcePicker.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(photoSourcePicker, animated: true, completion: nil)
    }
    
    func presentPhotoPicker(sourceType: UIImagePickerController.SourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        present(picker, animated: true, completion: nil)
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
                                let places = Dictionary<String, Any>()
                                let userData = ["provider": currentUser?.providerID, "email": email, "name": name, "photoRef": "Users/"+(currentUser?.uid)!+"/profile_pic.jpg", "UserPlaces" : places] as [String : Any]
                                
                                DataService.instance.createDBUser(uid: (currentUser?.uid)!, userData: userData as Dictionary<String, Any>)
                                
                                let profilePicRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                                
                                let uploadTask = profilePicRef.putData((self.photoBtn!.currentImage?.jpegData(compressionQuality: 1.0))! , metadata: nil){
                                    metadata, error in
                                    
                                    if (error == nil){
                                        DataService.instance.REF_USERS.child((currentUser?.uid)!+"/photoRef").setValue(metadata?.path)
                                    } else {
                                        print ("Error downloading image")
                                    }
                                }
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
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print("got image")
            photoBtn.setImage(image, for: .normal)
        }else {
            print("no image")
            let image = UIImage(named: "600px-Default_profile_picture_(male)_on_Facebook")
            photoBtn.setImage(image, for: .normal)
        }
    }
    
    
    
}
