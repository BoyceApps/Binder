//
//  PlaceTableViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/30/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class PlaceTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var starRating: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        photo.layer.cornerRadius = 6   //round the corner of photo
        photo.layer.masksToBounds = true
        photo.contentMode = .scaleAspectFill
        photo.layer.borderColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        photo.layer.borderWidth = 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
         self.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)

        // Configure the view for the selected state
    }

}
