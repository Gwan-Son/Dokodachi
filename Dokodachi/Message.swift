//
//  Message.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/8/24.
//

import Foundation

struct Message {
    let text: String
    let isIncoming: Bool
    let username: String
    
    init(text: String, isIncoming: Bool, username: String) {
        self.text = text
        self.isIncoming = isIncoming
        self.username = username
    }
}
