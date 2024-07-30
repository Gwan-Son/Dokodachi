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
    
    // Inputs
    let messageInput = PublishRelay<String>()
    
    // Outputs
    let messagesOutput = BehaviorRelay<[Message]>(value: [])
    
    init(username: String) {
        self.username = username
        
        messageInput
            .subscribe(onNext: { [weak self] message in
                self?.sendMessage(message)
            })
            .disposed(by: disposeBag)
        
        // Receive messages from the socket
        SocketIOManager.shared.messageObservable
            .subscribe(onNext: { [weak self] messageData in
                self?.receiveMessage(messageData)
            })
            .disposed(by: disposeBag)
    }
    
    private func sendMessage(_ message: String) {
        let currentTime = Date()
        let chatMessage = Message(text: message, isIncoming: false, username: username, time: currentTime)
        messagesOutput.accept(messagesOutput.value + [chatMessage])
        
        // Send the message to the server
        SocketIOManager.shared.sendMessage(username: username, message: message, time: currentTime)
    }
    
    private func receiveMessage(_ messageData: [String: Any]) {
        print("receiveMessage 호출!!")
        guard let username = messageData["username"] as? String,
              let message = messageData["message"] as? String,
              let timeString = messageData["time"] as? String else { return }
        
        let dateFormatter = ISO8601DateFormatter()
        guard let time = dateFormatter.date(from: timeString) else { return }
        
        let isIncoming = username != self.username
        let chatMessage = Message(text: message, isIncoming: isIncoming, username: username, time: time)
        messagesOutput.accept(messagesOutput.value + [chatMessage])
    }
}
