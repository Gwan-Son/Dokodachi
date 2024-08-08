//
//  SettingViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/22/24.
//

import UIKit
import FirebaseAuth

class SettingViewController: UIViewController {
    
    let tableView = UITableView()
    let sections = ["계정", "도움"]
    let settings = [
        ["계정", "보안"],
        ["도움말"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.isHidden = false
        self.title = "설정"
        tableView.delegate = self
        tableView.dataSource = self
        setupUI()
    }
    
    private func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "settingCell")
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

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingCell", for: indexPath)
        let item = settings[indexPath.section][indexPath.row]
        cell.textLabel?.text = item
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        var detailVC: UIViewController
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                detailVC = AccountViewController(auth: Auth.auth())
            } else {
                detailVC = PrivacyViewController(auth: Auth.auth())
            }
        } else {
            detailVC = DetailViewController()
        }
        detailVC.title = settings[indexPath.section][indexPath.row]
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
