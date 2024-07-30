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
        
        socket.on("send location") { [weak self] (dataArray, ack) in
            guard let locationData = dataArray.first as? [String: Any] else { return }
            self?.messageObservable.onNext(locationData)
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
    
    // chat message 와 send location 통합
    /*
     chat message는 sendButton으로 동작하기 때문에 node.js에서 broadcast.emit을 사용하여 중복 메시지를 제거함.
     send location은 mapView에서 동작하기 때문에 node.js에서 io.emit을 사용하여 나에게도 메시지가 보일 수 있게 수정함.
     */
    func sendMessage(username: String, message: Message) {
        var data: [String: Any] = [
            "username": username,
            "message": message.text,
            "time": ISO8601DateFormatter().string(from: message.time)
        ]
        
        if let latitude = message.latitude, let longitude = message.longitude {
            data["latitude"] = latitude
            data["longitude"] = longitude
            socket.emit("send location", data)
        } else {
            socket.emit("chat message", data)
        }
    }
}
