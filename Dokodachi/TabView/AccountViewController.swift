//
//  AccountViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 8/5/24.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    private let auth: Auth
    
    private let tableView = UITableView()
    private let sections = ["정보",""]
    private let infomations = [
        ["email","UID"],
        [""]
    ]
    
    private let emailLabel = UILabel()
    private let userIDLable = UILabel()
    private let logoutButton = UIButton(type: .roundedRect)
    
    init(auth: Auth) {
        self.auth = auth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
    }
    
    
    
    func setupUI() {
        view.backgroundColor = .white
        let user = auth.currentUser
        
        emailLabel.text = "로그인한 email: \(user?.email ?? "null")"
        emailLabel.font = UIFont.systemFont(ofSize: 18)
        emailLabel.textColor = .black
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emailLabel)
        
        userIDLable.text = "UID: \(user?.uid ?? "null")"
        userIDLable.font = UIFont.systemFont(ofSize: 16)
        userIDLable.textColor = .black
        userIDLable.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userIDLable)
        
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoutButton.setTitleColor(.white, for: .normal)
        logoutButton.backgroundColor = .red
        logoutButton.layer.cornerRadius = 5
        
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(logoutButton)
        
        NSLayoutConstraint.activate([
            emailLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            
            userIDLable.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userIDLable.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 30),
            
            logoutButton.topAnchor.constraint(equalTo: userIDLable.bottomAnchor, constant: 40),
            logoutButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            logoutButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            logoutButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc func logoutButtonTapped() {
        
        do {
            try auth.signOut()
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("-----SignOut ERROR-----")
        }
    }
}

extension AccountViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infomations[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "accountCell", for: indexPath)
        let item = infomations[indexPath.section][indexPath.row]
        cell.textLabel?.text = item
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}
