//
//  PlaceCollectionViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/9/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class PlaceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var placePhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        placePhoto.layer.cornerRadius = placePhoto.frame.height/2
        placePhoto.layer.masksToBounds = true
        placePhoto.contentMode = .scaleAspectFill
        placePhoto.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        placePhoto.layer.borderWidth = 2
    }
}
