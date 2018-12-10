//
//  PlaceTableViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 11/29/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePhoto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profilePhoto.layer.cornerRadius = (profilePhoto.frame.size.height/2) //round the corner of photo
        profilePhoto.layer.masksToBounds = true
        profilePhoto.layer.borderWidth = 2
        profilePhoto.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        profilePhoto.contentMode = .scaleAspectFit
        profilePhoto.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        profilePhoto.layer.shadowOpacity = 0.5
        profilePhoto.layer.shadowRadius = 0.5
        profilePhoto.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }

}
