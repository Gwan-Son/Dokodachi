//
//  LocationModel.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/27/24.
//

import Foundation

struct LocationModel {
    let latitude: String
    let longitude: String
    
    init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
    }
}
