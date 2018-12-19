//
//  ChatTableViewCell.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/9/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    
    @IBOutlet weak var chatPhoto: UIImageView!
    
    @IBOutlet weak var chatLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        chatPhoto.layer.masksToBounds = true
        chatPhoto.contentMode = .scaleAspectFill
        chatPhoto.layer.cornerRadius = (chatPhoto.frame.size.height/2) //round the corner of photo
        chatPhoto.layer.borderWidth = 2
        chatPhoto.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        chatPhoto.layer.shadowColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        chatPhoto.layer.shadowOpacity = 0.5
        chatPhoto.layer.shadowRadius = 0.5
        chatPhoto.layer.shadowOffset = CGSize.init(width: 0.5, height: 0.5)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
