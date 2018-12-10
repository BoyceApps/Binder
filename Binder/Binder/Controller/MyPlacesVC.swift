//
//  MyPlacesVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/29/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import SwipeCellKit

class MyPlacesVC: UIViewController, UITableViewDelegate, UITableViewDataSource, SwipeTableViewCellDelegate{
    
    var myPlaces = MY_PLACES
    var placeArray: [String]?
    let imageCache = NSCache<AnyObject, AnyObject>()
    
    @IBOutlet weak var myPlacesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        DataService.instance.updateUserPlaces()
        myPlaces = MY_PLACES
        placeArray = []
        if myPlaces != nil {
            for key in myPlaces {
                placeArray?.append(key.key)
            }
        }
        myPlacesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPlacesTableView.delegate = self
        myPlacesTableView.dataSource = self
       myPlacesTableView.reloadData()
        print(placeArray)
    }
    
    //TableView delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return placeArray?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyPlaceCell", for: indexPath) as! MyPlaceTableViewCell
        
        cell.delegate = self
        
        let placeID = placeArray?[indexPath.row]
        
        var place = myPlaces[placeID!] as! Dictionary<String, Any>
    
        cell.nameLbl.text = place.removeValue(forKey: "name") as! String
        
        if let imageFromCache = imageCache.object(forKey: placeID as AnyObject) as? UIImage{
            cell.photo.image = imageFromCache
        }else{
        
        let placePhotoRef = DataService.instance.REF_STORAGE_PLACES.child(placeID!+"/placePic.jpg")
                    placePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                            if (error != nil) {
                                print("Error downloading place image")
                            }else {
                                
                                if (data != nil){
                                    DispatchQueue.main.async {
                                        let imageToCache = UIImage(data: data!)
                                        
                                        if placeID == self.placeArray![indexPath.row]{
                                              cell.photo.image = imageToCache
                                        }
                                        self.imageCache.setObject(imageToCache!, forKey: placeID as AnyObject)
                                        
                                        //cell.photo.image = imageToCache
                                    }
                                    
                                }
                            }
                    })
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        
        guard orientation == .right else { return nil }
        
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { action, indexPath in
            // handle action by updating model with deletion
            
           
            DataService.instance.removeUserPlace(placeID: self.placeArray![indexPath.row])
            self.placeArray?.remove(at: indexPath.row)
             self.myPlacesTableView.reloadData()
            
        }
        
        // customize the action appearance
        deleteAction.image = UIImage(named: "delete-icon")
        
        return [deleteAction]
    }
    
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "OpenPlaceChat", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenPlaceChat" {
                let destinationVC = segue.destination as! PlaceChatVC
        
                if let indexPath = myPlacesTableView.indexPathForSelectedRow {
                    let placeID = placeArray?[indexPath.row]
                    destinationVC.placeID = placeID
        
                    DataService.instance.REF_PLACES.child(placeID!).observeSingleEvent(of: .value, with: { (snapshot) in
        
                        let place = snapshot.value as? NSDictionary
        
                        if place?.object(forKey: "name") as? String != nil {
                            let name = (place?.object(forKey: "name") as? String)!
                            destinationVC.name = name
                        }
        
                })
            }
        }
    }

    @IBAction func refreshButtonPressed(_ sender: Any) {
        DataService.instance.updateUserPlaces()
        myPlaces = MY_PLACES
        placeArray = []
        for key in myPlaces {
            placeArray?.append(key.key)
        }
        myPlacesTableView.reloadData()
    }
    
}
