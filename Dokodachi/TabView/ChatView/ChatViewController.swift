//
//  ViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 6/21/24.
//

import UIKit
import RxSwift
import RxCocoa


class ChatViewController: UIViewController, ChatMessageCellDelegate {
    
    private let tableView = UITableView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    private let userView = UIView()
    
    private let viewModel: ChatViewModel
    private let disposeBag = DisposeBag()
    
    var userViewYValue = CGFloat(0)
    
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
        view.backgroundColor = UIColor(hexCode: "B4D6CD")

        
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: "ChatMessageCell")
        tableView.separatorStyle = .none
        
        tableView.allowsSelection = false
        tableView.backgroundColor = UIColor(hexCode: "B4D6CD")
        tableView.keyboardDismissMode = .onDrag
        
        messageTextField.borderStyle = .roundedRect
        messageTextField.placeholder = "Enter message"
        messageTextField.clearButtonMode = .whileEditing
        
        sendButton.setTitle("Send", for: .normal)
        
        userView.backgroundColor = .white
        userView.addSubview(messageTextField)
        userView.addSubview(sendButton)
        
        view.addSubview(tableView)
        view.addSubview(userView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        messageTextField.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        userView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: userView.topAnchor, constant: -10),
            
            userView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            userView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            userView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            userView.heightAnchor.constraint(equalToConstant: 50),
            
            messageTextField.leadingAnchor.constraint(equalTo: userView.leadingAnchor, constant: 10),
            messageTextField.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -10),
            messageTextField.centerYAnchor.constraint(equalTo: userView.centerYAnchor),
            messageTextField.heightAnchor.constraint(equalToConstant: 44),
            
            sendButton.trailingAnchor.constraint(equalTo: userView.trailingAnchor, constant: -10),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 60),
            sendButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        print("userView Y값: \(userView.frame.origin.y)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    private func setupBindings() {
        sendButton.rx.tap
            .withLatestFrom(messageTextField.rx.text.orEmpty)
            .filter { !$0.isEmpty }
            .do(onNext: { [weak self] _ in
                self?.messageTextField.text = nil
            })
            .bind(to: viewModel.messageInput)
            .disposed(by: disposeBag)
        
        viewModel.messagesOutput
            .bind(to: tableView.rx.items(cellIdentifier: "ChatMessageCell", cellType: ChatMessageCell.self)) { index, message, cell in
                cell.configure(with: message)
                cell.delegate = self
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
    
    func mapButtonTapped(in cell: ChatMessageCell, latitude: Double, longitude: Double, username: String) {
        NotificationCenter.default.post(name: NSNotification.Name("ShowLocation"), object: nil, userInfo: ["latitude": latitude, "longitude": longitude, "username": username])
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = 2
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardFrame.height
            print("키보드 높이: \(keyboardHeight)")
            print("현재 뷰 위치: \(self.userView.frame.origin.y)")
            print("현재 뷰 크기: \(self.userView.frame.height)")
            let newYPosition = self.userView.frame.origin.y + keyboardHeight
            
            UIView.animate(withDuration: 0.3) {
                self.userView.frame.origin.y = newYPosition
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.userView.frame.origin.y != 0 {
            self.userView.frame.origin.y = 0
        }
        print("userView Y 값: \(self.userView.frame.origin.y)")
    }
    
    deinit {
        SocketIOManager.shared.disconnect()
    }
    
    
}

