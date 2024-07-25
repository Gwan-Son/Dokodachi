//
//  SettingViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/22/24.
//

import UIKit

class SettingViewController: UIViewController {
    
    let tableView = UITableView()
    let sections = ["일반", "계정", "도움"]
    let settings = [
        ["알림 설정", "다크 모드"],
        [ "계정", "보안"], 
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
        
        if indexPath.section == 0 && indexPath.row < 2 { // Switches in the first section
            let switchView = UISwitch(frame: .zero)
            switchView.tag = indexPath.row
            if indexPath.row == 0 { // Enable Notifications switch
                switchView.setOn(UserDefaults.standard.bool(forKey: "enable_notifications"), animated: true)
                switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            } else if indexPath.row == 1 { // Dark Mode switch
                switchView.setOn(UserDefaults.standard.bool(forKey: "dark_mode"), animated: true)
                switchView.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            }
            cell.accessoryView = switchView
        } else {
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
    
    @objc func switchChanged(_ sender: UISwitch) {
        if sender.tag == 0 {
            UserDefaults.standard.set(sender.isOn, forKey: "enable_notifications")
        } else if sender.tag == 1 {
            UserDefaults.standard.set(sender.isOn, forKey: "dark_mode")
            // Here you can also add code to change the appearance of the app if needed
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section > 0 || indexPath.row >= 2 {
            let detailVC = DetailViewController()
            detailVC.title = settings[indexPath.section][indexPath.row]
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}
