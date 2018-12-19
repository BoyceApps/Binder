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
    private var _senderUid: String
    private var _date: String
    
    var content: String {
        return _content
    }
    
    var senderUid: String {
        return _senderUid
    }
    
    var date: String {
        return _date
    }
    
    init(content: String, senderUid: String, date: String) {
        self._content = content
        self._senderUid = senderUid
        self._date = date
    }
}
