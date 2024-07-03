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
    let messageOutput: Observable<[String]>
    
    init() {
        let messages = messageInput
            .map { $0 }
            .scan([String]()) { (currentMessages, newMessage) in
                return currentMessages + [newMessage]
            }
        
        messageOutput = messages
            .startWith([])
            .observe(on: MainScheduler.instance)
        
        NotificationCenter.default.rx.notification(.newMessage)
            .map { $0.object as? String }
            .filter { $0 != nil }
            .map { $0! }
            .bind(to: messageInput)
            .disposed(by: disposeBag)
    }
}
