//
//  MyPlaceTableViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/2/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit
import SwipeCellKit

class MyPlaceTableViewCell: SwipeTableViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var bgView: UIView!
    
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
        // Configure the view for the selected state
        
    }
    
}
