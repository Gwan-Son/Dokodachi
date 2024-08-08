//
//  PrivacyViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 8/5/24.
//

import UIKit
import FirebaseAuth

class PrivacyViewController: UIViewController {
    private let auth: Auth
    
    private let tableView = UITableView()
    let sections = ["Old Password", "New Password"]
    let password = [
        ["기존 비밀번호:"],
        ["새 비밀번호:","새 비밀번호 확인:"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setupUI()
    }
    
    init(auth: Auth) {
        self.auth = auth
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "PrivacyCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

extension PrivacyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return password[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //TODO: - CustomCell 설정
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyCell", for: indexPath) as! PrivacyCell
        let item = password[indexPath.section][indexPath.row]
        cell.congifure(text: item, placeholder: "비밀번호를 입력해주세요.")
        
        return cell
    }
    
}
