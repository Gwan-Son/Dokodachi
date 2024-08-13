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
    let sections = ["New Password","Confirm"]
    let password = [
        ["새 비밀번호:","새 비밀번호 확인:"],
        [""]
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
        tableView.register(PrivacyCell.self, forCellReuseIdentifier: "PrivacyCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func changePassword() {
        var newPassword: String = ""
        var confirmPassword: String = ""
        
        for row in 0..<password[0].count {
            let indexPath = IndexPath(row: row, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) as? PrivacyCell {
                let textFieldValue = cell.passwordTextField.text
                if textFieldValue == "" || textFieldValue == nil {
                    errorPassword()
                } else {
                    if row == 0 {
                        newPassword = textFieldValue!
                    } else {
                        confirmPassword = textFieldValue!
                    }
                }
                
            }
        }
        
        if newPassword == confirmPassword {
            if checkPasswordValid(newPassword) {
                //TODO: - 비밀번호 변경 로직
                let user = auth.currentUser
                user?.updatePassword(to: newPassword) { [self] (error) in
                    if error != nil {
                        let alert = UIAlertController(title: "오류 발생", message: "오류가 발생했습니다. 나중에 다시 시도해주세요.", preferredStyle: .alert)
                        alert.addAction(.init(title: "확인", style: .default))
                        self.present(alert, animated: true)
                    } else {
                        successChangePassword()
                    }
                }
            } else {
                errorPassword()
            }
            
        } else {
            errorPassword()
        }
        
    }
    
    func errorPassword() {
        let alert = UIAlertController(title: "잘못된 비밀번호", message: "비밀번호를 확인해주세요.", preferredStyle: .alert)
        alert.addAction(.init(title: "확인", style: .default))
        self.present(alert, animated: true)
    }
    
    func successChangePassword() {
        let alert = UIAlertController(title: "비밀번호 변경 성공", message: "비밀번호 변경이 완료되었습니다. 안전한 로그인을 위해 초기 화면으로 돌아갑니다.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            self.dismiss(animated: true)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true)
    }
    
    func checkPasswordValid(_ password: String) -> Bool {
        let pattern = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: password)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "PrivacyCell", for: indexPath) as! PrivacyCell
        let item = password[indexPath.section][indexPath.row]
        if indexPath.section == 0 {
            cell.congifure(text: item, placeholder: "비밀번호를 입력해주세요.")
            cell.selectionStyle = .none
        } else {
            cell.buttonConfigure()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1 && indexPath.row == 0 {
            changePassword()
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
}
