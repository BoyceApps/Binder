//
//  Message.swift
//  Binder
//
//  Created by Boyce Whisenant on 12/2/18.
//  Copyright © 2018 Boyce Whisenant. All rights reserved.
//

import UIKit

class Message {
    
    private var _content: String
    private var _senderId: String
    private var _date: String
    
    var content: String {
        return _content
    }
    
    var senderId: String {
        return _senderId
    }
    
    var date: String {
        return _date
    }
    
    init(content: String, senderId: String, date: String) {
        self._content = content
        self._senderId = senderId
        self._date = date
    }
}
