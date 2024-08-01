//
//  ChatMessageCellDelegate.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/31/24.
//

import Foundation

protocol ChatMessageCellDelegate: AnyObject {
    func mapButtonTapped(in cell: ChatMessageCell, latitude: Double, longitude: Double, username: String)
}
