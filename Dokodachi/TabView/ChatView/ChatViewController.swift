//
//  ViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 6/21/24.
//

import UIKit
import RxSwift
import RxCocoa


class ChatViewController: UIViewController {
    
    private let tableView = UITableView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private let viewModel: ChatViewModel
    private let disposeBag = DisposeBag()
    
    init(username: String) {
        self.viewModel = ChatViewModel(username: username)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ChatViewController 실행됨")
        
        setupUI()
        setupBindings()
        
        SocketIOManager.shared.connect()
    }
    
    private func setupUI() {
        view.backgroundColor = .white

        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        tableView.backgroundColor = .gray
        
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Enter message"
        
        sendButton.setTitle("Send", for: .normal)
        
        view.addSubview(tableView)
        view.addSubview(messageTextField)
        view.addSubview(sendButton)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: messageTextField.topAnchor, constant: -10),
            
            messageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            messageTextField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
            
        ])
    }
    
    private func setupBindings() {
        sendButton.rx.tap
            .withLatestFrom(messageTextField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .do(onNext: { [weak self] _ in
                self?.messageTextField.text = ""
            })
            .bind(to: viewModel.messageInput)
            .disposed(by: disposeBag)
        
        viewModel.messagesOutput
            .bind(to: tableView.rx.items(cellIdentifier: "ChatMessageCell", cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
            }
            .disposed(by: disposeBag)
        
        // 채팅이 tableView 아래에 추가될 때 마다 자동 스크롤되는 기능
        viewModel.messagesOutput
            .subscribe(onNext: {[weak self] _ in
                self?.scrollToBottom()
            })
            .disposed(by: disposeBag)
    }
    
    // 채팅이 tableView 아래에 추가될 때 마다 자동 스크롤되는 기능
    private func scrollToBottom() {
        let numberOfRows = tableView.numberOfRows(inSection: 0)
        if numberOfRows > 0 {
            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    deinit {
        SocketIOManager.shared.disconnect()
    }
    
    
}

