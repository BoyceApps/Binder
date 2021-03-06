//
//  StarRating.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/1/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class StarRating: UIImage {
    class func rating(rating: Double) -> (UIImage){
        var ratingImage: UIImage
        
        switch rating {
        case 0.0:
            ratingImage = UIImage(named:"zerostars")!
        case 0..<1.0:
            ratingImage = UIImage(named:"onestars")!
        case 1.0:
            ratingImage = UIImage(named:"onestars")!
        case 1.0..<2.0:
            ratingImage = UIImage(named:"onehalfstars")!
        case 2.0:
            ratingImage = UIImage(named:"twostars")!
        case 2.0..<3.0:
            ratingImage = UIImage(named:"twohalfstars")!
        case 3.0:
            ratingImage = UIImage(named:"threestars")!
        case 3.0..<4.0:
            ratingImage = UIImage(named:"threehalfstars")!
        case 4.0:
            ratingImage = UIImage(named:"fourstars")!
        case 4.0..<5.0:
            ratingImage = UIImage(named:"fourhalfstars")!
        case 5.0:
            ratingImage = UIImage(named:"fivestars")!
        default:
            ratingImage = UIImage(named:"zerostars")!
        }
        return ratingImage
    }
}
