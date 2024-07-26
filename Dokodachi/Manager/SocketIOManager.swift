//
//  SocketIOManager.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/2/24.
//

import UIKit
import SocketIO
import RxSwift

class SocketIOManager {
    static let shared = SocketIOManager()
    
    private let manager: SocketManager
    private let socket: SocketIOClient
    private let disposeBag = DisposeBag()
    
    let messageObservable = PublishSubject<[String: Any]>()
    
    private init() {
        self.manager = SocketManager(socketURL: URL(string: "http://localhost:3000")!, config: [.log(true), .compress])
        self.socket = manager.defaultSocket
        //        setupSocketEvents()
        setupBindings()
    }
    
    private func setupBindings() {
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket connected")
        }
        
        socket.on("chat message") { [weak self] (dataArray, ack) in
            guard let messageData = dataArray.first as? [String: Any] else { return }
            self?.messageObservable.onNext(messageData)
        }
        
        socket.on(clientEvent: .disconnect) {data, ack in
            print("Socket disconnected")
        }
        
        socket.on(clientEvent: .error) {data, ack in
            print("Socket error: \(data)")
        }
        
        socket.on(clientEvent: .statusChange) {data, ack in
            print("Socket status change: \(data)")
        }
        
    }
    
    func connect() {
        socket.connect()
        print("소켓 연결")
    }
    
    func disconnect() {
        socket.disconnect()
    }
    
    func sendMessage(username: String, message: String, time: Date) {
        let dateFormatter = ISO8601DateFormatter()
        let timeString = dateFormatter.string(from: time)
        let messageData: [String: Any] = ["username": username, "message": message, "time": timeString]
        socket.emit("chat message", messageData)
    }
    
    //    func sendLocation(latitude: Double, longitude: Double) {
    //        socket.emit("sendLocation", ["latitude": latitude, "longitude": longitude])
    //    }
}
