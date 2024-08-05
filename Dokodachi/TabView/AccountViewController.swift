//
//  AccountViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 8/5/24.
//

import UIKit
import FirebaseAuth

class AccountViewController: UIViewController {
    
    private let logoutButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .blue
    }
    
    func setupUI() {
        logoutButton.setTitle("로그아웃", for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        logoutButton.backgroundColor = .green
        logoutButton.addTarget(self, action: #selector(<#T##@objc method#>), for: .touchUpInside)
    }
    
    @objc func logoutButtonTapped() {
        do {
            Auth.signOut(<#T##self: Auth##Auth#>)
            try FIRAuth.signOut()
        } catch {
            print("-----SignOut ERROR-----")
        }
    }
}
