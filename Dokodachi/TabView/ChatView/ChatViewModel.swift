//
//  ChatViewModel.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/2/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatViewModel {
    private let disposeBag = DisposeBag()
    private let username: String
    
    let messageInput = PublishRelay<String>()
    let messagesOutput = BehaviorRelay<[Message]>(value: [])
    
    init(username: String) {
        self.username = username
        
        messageInput
            .subscribe(onNext: { [weak self] message in
                self?.sendMessage(message)
            })
            .disposed(by: disposeBag)
        
        SocketIOManager.shared.messageObservable
            .subscribe(onNext: { [weak self] messageData in
                self?.receiveMessage(messageData)
            })
            .disposed(by: disposeBag)
    }
    
    private func sendMessage(_ message: String) {
        let chatMessage = Message(text: message, isIncoming: false, username: username, time: Date())
        messagesOutput.accept(messagesOutput.value + [chatMessage])
        
        SocketIOManager.shared.sendMessage(username: username, message: chatMessage)
    }
    
    private func receiveMessage(_ messageData: [String: Any]) {
        guard let username = messageData["username"] as? String,
              let message = messageData["message"] as? String,
              let timeString = messageData["time"] as? String,
              let time = ISO8601DateFormatter().date(from: timeString) else { return }
        
        let latitude = messageData["latitude"] as? Double
        let longitude = messageData["longitude"] as? Double
        
        let isIncoming = username != self.username
        let chatMessage = Message(text: message, isIncoming: isIncoming, username: username, time: time, latitude: latitude, longitude: longitude)
        messagesOutput.accept(messagesOutput.value + [chatMessage])
    }
}
