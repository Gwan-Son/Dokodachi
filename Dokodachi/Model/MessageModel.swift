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
    let time: Date
    let latitude: Double?
    let longitude: Double?
    
    init(text: String, isIncoming: Bool, username: String, time: Date, latitude: Double? = nil, longitude: Double? = nil) {
        self.text = text
        self.isIncoming = isIncoming
        self.username = username
        self.time = time
        self.latitude = latitude
        self.longitude = longitude
    }
}
