//
//  FindPlacesVC.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/29/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

import CoreLocation

class FindPlacesVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
  
  
    var myPlaces = MY_PLACES
    var placeArray = [Place]()
    var localPlaces: [Place]?{
        didSet{
            activity.stopAnimating()
            activity.isHidden = true
            placesTableView.reloadData()
        }
    }
    
    var latitude: Double = 33.920248
    
    var longitude: Double = -81.221063
    
    var locationManager: CLLocationManager!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    @IBOutlet weak var placesTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        DataService.instance.updateUserPlaces()
        myPlaces = MY_PLACES
        placesTableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesTableView.delegate = self
        placesTableView.dataSource = self
        setupLocationManager()
        activity.isHidden = false
        activity.startAnimating()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return localPlaces?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        
        var place = localPlaces![indexPath.row]
        
        
        cell.accessoryType = place.selected ? .checkmark: .none
        
        
        cell.name.text = place.name
        
        if let photo = place.photo{
            cell.photo.image = UIImage(data: photo)
        }else{
            if place.photo == nil{
                print("no pic")
                let profilePhotoRef = DataService.instance.REF_STORAGE_USERS.child((currentUser?.uid)!+"/profile_pic.jpg")
                
                profilePhotoRef.getData(maxSize: (1*1024*1024), completion: { (data, error) in
                    if (error != nil) {
                        print("Error downloading profile image")
                    }else {
                        if (data != nil){
                            cell.photo.image = UIImage(data: data!)
                        }
                    }
                    
                    
                })
            }
        }
        let rating = place.rating
        cell.starRating.image = StarRating.rating(rating: rating)
        
        return cell
    }
    
    //User selected a place
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //performSegue(withIdentifier: "openPlaceChat", sender: self)
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as! PlaceTableViewCell
        
        var place = localPlaces![indexPath.row]
        
            place.selected = !place.selected
            //if selected is true save to myPlaces
            if (place.selected == true){
                print("Adding Place")
                cell.accessoryType = .checkmark
                
                var placeDict = Dictionary<String,Any>()
                placeDict.updateValue(place.name, forKey: "name")
                placeDict.updateValue(place.latitude, forKey: "lat")
                placeDict.updateValue(place.longitude, forKey: "lng")
                placeDict.updateValue("Places/\(place.placeID)/placePic.jpg", forKey: "photoRef")
                placeDict.updateValue(place.rating, forKey: "rating")
              
                DataService.instance.updateUserPlaces(placeID: place.placeID, userPlace: placeDict)
            }else{
                print("Removing Place")
                cell.accessoryType = .none
                myPlaces[place.placeID] = nil
                DataService.instance.removeUserPlace(placeID: place.placeID)
            }
        
        localPlaces![indexPath.row] = place
    
        
        placesTableView.deselectRow(at: indexPath, animated: true)
        
        placesTableView.reloadData()
        
    }
    
    //Get Location
    func setupLocationManager(){
        
        locationManager = CLLocationManager()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            //locationManager.startUpdatingHeading()
            print("get location")
            locationManager.startUpdatingLocation()
        }
    }
    
    //once location is found get places
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //stop location manager
        print("getting location")
        self.locationManager.stopUpdatingLocation()
        self.locationManager.delegate = nil
        
        if let currentLocation: CLLocation = locations.last {
            
            //print(currentLocation)
            latitude = currentLocation.coordinate.latitude
            longitude = currentLocation.coordinate.longitude
            
            getPlaces()
        }
        
        
    }
    
    //use location to find local bars
    func getPlaces(){
        
        let params: [String:Any] = ["key": googleApiKey, "radius": "10000", "keyword": "bar", "location": "\(latitude)," + "\(longitude)",
            "rankBy": "distance", "type": "bar"]
        
        print("requesting places")
        
        Alamofire.request(GoogleApiPlaceSearchJson, method: .get, parameters: params)
            .responseJSON {
                response in
                if response.result.isSuccess {
                    
                    print("got Data")
                    
                    let json : JSON = JSON(response.result.value!)
                    
                    
                    self.createFrom(incomingJSON: json)
                    
                    print("Setting local places")
                    self.placesTableView.reloadData()
                    
                }
        }
    }
    
    func createFrom(incomingJSON: SwiftyJSON.JSON){
        let jsonPlaces = incomingJSON["results"].array
        
        for subJSON in jsonPlaces! {
            var place: Place?
            
            if let name = subJSON["name"].rawString(),
                let rating = subJSON["rating"].double,
                let location = subJSON["geometry"]["location"].dictionaryObject,
                let placeID = subJSON["place_id"].rawString(),
                let photos = subJSON["photos"].arrayObject{
                
                var exists = false
                
                if name.contains("Applebee"){
                        exists = true
                    }
                if name.contains("Charley"){
                        exists = true
                    }
                if name.contains("Buffalo"){
                        exists = true
                    }
                for myPlace in self.myPlaces {
                    if myPlace.key == placeID{
                        exists = true
                    }
                }
                
               if !exists {
                
                    if(photos.count > 0){
                        let photoDict:NSDictionary = photos[0] as! NSDictionary
                        if  let photoReference = photoDict["photo_reference"],
                            let latitude  = location["lat"],
                            let longitude = location["lng"]{
            
                            //Get Place Photo
                            let photoParams: [String:Any] = ["maxwidth" : 400, "photoreference" : "\(String(describing: photoReference))", "key": googleApiKey]
                            
                                Alamofire.request(GoogleApiPlaceSearchPhoto, method: .get, parameters: photoParams).response{
                                    (DefaultDataResponse) in
         
                                        if let imageData = DefaultDataResponse.data {
                                            
                                                let placePicRef = DataService.instance.REF_STORAGE_PLACES.child(placeID+"/placePic.jpg")
                                            
                                                let uploadTask = placePicRef.putData(imageData as Data, metadata: nil){
                                                    metadata, error in
                                                    
                                                    if (error == nil){
                                                        //successfully uploaded data to storage
                                                        print("Adding Place to local places")
                                                        place = Place(name: name, rating: rating, latitude: longitude as! Double, longitude: latitude as! Double, placeID: placeID, photoReference: photoReference as! String, selected: false)
                                                        place!.photo = imageData
                                                        if self.localPlaces == nil {
                                                            self.localPlaces = []
                                                        }
                                                        self.localPlaces?.append(place!)
                                                        
                                                        let placeData = ["name": name, "rating": rating, "lat": latitude, "lng": longitude, "photoRef": metadata?.path]
                                                        
                                                        
                                                        DataService.instance.createNewPlace(placeID: placeID, placeData: placeData as Dictionary<String, Any>)
                                                        
                                                    } else {
                                                        print ("Error downloading image")
                                                    }
                                                }
                                        }
                                        
                                    }
                                    
                                }
                        }
                    }
                    
                }

            }
        
        }
    
    
    @IBAction func doneBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    

}
