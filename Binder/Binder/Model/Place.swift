//
//  Place.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/1/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import Foundation

struct Place {
    var placeID: String = ""
    var name: String = ""
    var rating: Double = 0.0
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var photoReference: String? = ""
    var photo: Data? = nil
    var selected: Bool = false
    
    
    //initializer
    init(name: String, rating: Double, latitude: Double, longitude: Double, placeID: String, photoReference: String, selected: Bool){
        
        self.name = name
        self.rating = rating
        self.latitude = latitude
        self.longitude = longitude
        self.placeID = placeID
        self.photoReference = photoReference
        self.photo = nil
        self.selected = selected
        
        
    }
}
