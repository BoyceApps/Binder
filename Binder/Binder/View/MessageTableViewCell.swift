//
//  MessageTableViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/2/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
  
    @IBOutlet weak var userPhoto: UIImageView!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var messageLbl: UILabel!
    @IBOutlet weak var messageBackground: UIView!
    @IBOutlet weak var leftMargin: NSLayoutConstraint!
    @IBOutlet weak var rightMargin: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userPhoto.layer.masksToBounds = true
        userPhoto.contentMode = .scaleAspectFit
        
        userPhoto.layer.cornerRadius = (userPhoto.frame.size.height/2) //round the corner of photo
        userPhoto.layer.borderWidth = 2
        userPhoto.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        userPhoto.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        userPhoto.layer.shadowOpacity = 0.5
        userPhoto.layer.shadowRadius = 0.5
        userPhoto.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
        messageBackground.layer.cornerRadius = 12
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
