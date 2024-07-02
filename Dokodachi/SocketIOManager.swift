//
//  SocketIOManager.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/2/24.
//

import UIKit
import SocketIO

class SocketIOManager {
    static let shared = SocketIOManager()
    
    private var manager: SocketManager
    private var socket: SocketIOClient
    
    private init() {
        self.manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        setupSocketEvents()
    }
    
    func connect() {
        socket.connect()
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendMessage(_ message: String) {
        socket.emit("sendMessage", message)
    }
    
    func sendLocation(latitude: Double, longitude: Double) {
        socket.emit("sendLocation", ["latitude": latitude, "longitude": longitude])
    }
    
    private func setupSocketEvents() {
        socket.on(clientEvent: .connect) { data, ack in
            print("Socket connected")
        }
        
        socket.on("newMessage") { data, ack in
            if let message = data[0] as? String {
                NotificationCenter.default.post(name: .newMessage, object: message)
            }
        }
        
        socket.on("newLocation") { (data, ack) in
            if let locationData = data[0] as? [String: Double],
               let latitude = locationData["latitude"],
               let longitude = locationData["longitude"] {
                let location = (latitude: latitude, longitude: longitude)
                NotificationCenter.default.post(name: .newLocation, object: location)
            }
        }
        
        socket.on(clientEvent: .disconnect) { data, ack in
            print("Socket disconnected")
        }
    }
}

extension Notification.Name {
    static let newMessage = Notification.Name("newMessage")
    static let newLocation = Notification.Name("newLocation")
}
