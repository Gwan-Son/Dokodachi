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
        let chatMessage = Message(text: message, isIncoming: false, username: username)
        messagesOutput.accept(messagesOutput.value + [chatMessage])
        
        // Send the message to the server
        SocketIOManager.shared.sendMessage(username: username, message: message)
    }
    
    private func receiveMessage(_ messageData: [String: Any]) {
        guard let username = messageData["username"] as? String,
              let message = messageData["message"] as? String else { return }
        
        let isIncoming = username != self.username
        let chatMessage = Message(text: message, isIncoming: isIncoming, username: username)
        messagesOutput.accept(messagesOutput.value + [chatMessage])
    }
}
