//
//  ViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 6/21/24.
//

import UIKit
import RxSwift
import RxCocoa


class ViewController: UIViewController {
    
    private let tableView = UITableView()
    private let messageTextField = UITextField()
    private let sendButton = UIButton(type: .system)
    
    private let viewModel = ChatViewModel()
    private let disposeBag = DisposeBag()
    private let locationManager = LocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBindings()
        
        SocketIOManager.shared.connect()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
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
            .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, message, cell in
                cell.textLabel?.text = message
            }
            .disposed(by: disposeBag)
    }
    
    deinit {
        SocketIOManager.shared.disconnect()
    }
    
    
}

extension ViewController {
    static func setupAppDelegate() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = ViewController()
        window.makeKeyAndVisible()
        appDelegate.window = window
    }
}
