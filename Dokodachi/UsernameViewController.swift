//
//  UsernameViewControlloer.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/10/24.
//

import UIKit

class UsernameViewController: UIViewController {
    private let usernameTextField = UITextField()
    private let continueButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        usernameTextField.borderStyle = .roundedRect
        usernameTextField.placeholder = "Enter username"
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        
        view.addSubview(usernameTextField)
        view.addSubview(continueButton)
        
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            usernameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            usernameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            usernameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            continueButton.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            continueButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            continueButton.widthAnchor.constraint(equalToConstant: 100),
            continueButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        
    }
    
    @objc private func continueButtonTapped() {
        guard let username = usernameTextField.text, !username.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Username cannot be empty", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }
        print("Username entered: \(username)")
        let chatVC = ViewController(username: username)
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
}
