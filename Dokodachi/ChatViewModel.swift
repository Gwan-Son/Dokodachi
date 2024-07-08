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
    
    // Inputs
    let messageInput = PublishSubject<String>()
    private let messagesSubject = BehaviorSubject<[Message]>(value: [])
    
    // Outputs
    var messagesOutput: Observable<[Message]> {
        return messagesSubject.asObservable()
    }
    
    init() {
        messageInput
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                var currentMessages = (try? self.messagesSubject.value()) ?? []
                let newMessage = Message(text: message, isImcoming: false)
                currentMessages.append(newMessage)
                self.messagesSubject.onNext(currentMessages)
                SocketIOManager.shared.sendMessage(message)
            })
            .disposed(by: disposeBag)
        
        SocketIOManager.shared.messageReceived
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                var currentMessages = (try? self.messagesSubject.value()) ?? []
                let newMessage = Message(text: message, isImcoming: true)
                currentMessages.append(newMessage)
                self.messagesSubject.onNext(currentMessages)
            })
            .disposed(by: disposeBag)
        
//        NotificationCenter.default.rx.notification(.newMessage)
//            .compactMap { $0.object as? String }
//            .subscribe(onNext: { [weak self] message in
//                guard let self = self else { return }
//                var currentMessages = self.messagesOutput.value
//                currentMessages.append(message)
//                self.messagesOutput.accept(currentMessages)
//            })
//            .disposed(by: disposeBag)
    }
}
