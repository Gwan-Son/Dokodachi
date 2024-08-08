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
    private let sections = ["정보","계정"]
    private let infomations = [
        ["email","UID"],
        ["로그아웃"]
    ]
    
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
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "accountCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func logoutButtonTapped() {
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
        var config = UIListContentConfiguration.cell()
        
        config.text = item
        
        if indexPath.section == 0 {
            let user = auth.currentUser
            cell.selectionStyle = .none
            config.secondaryTextProperties.color = .gray
            if indexPath.row == 0 {
                config.secondaryText = user?.email ?? "null"
            } else {
                config.secondaryText = user?.uid ?? "null"
            }
        } else {
            config.textProperties.alignment = .center
            config.textProperties.color = .red
        }
        cell.contentConfiguration = config
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            logoutButtonTapped()
        }
    }

}
