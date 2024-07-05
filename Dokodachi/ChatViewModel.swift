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
    
    // Outputs
    let messagesOutput = BehaviorRelay<[String]>(value: [])
    
    init() {
        messageInput
            .subscribe(onNext: { message in
                SocketIOManager.shared.sendMessage(message)
            })
            .disposed(by: disposeBag)
        
        
        NotificationCenter.default.rx.notification(.newMessage)
            .compactMap { $0.object as? String }
            .subscribe(onNext: { [weak self] message in
                guard let self = self else { return }
                var currentMessages = self.messagesOutput.value
                currentMessages.append(message)
                self.messagesOutput.accept(currentMessages)
            })
            .disposed(by: disposeBag)
    }
}
