//
//  LoginViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/18/24.
//

import UIKit
import FirebaseAuth
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let emailInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let emailValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let pwInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    
    
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "example@example.com"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "password"
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = UIColor(.accentColor)
        button.setTitle("Enter email & password", for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        self.title = "Login"
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            
            emailTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emailTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            emailTextField.heightAnchor.constraint(equalToConstant: 44),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            passwordTextField.heightAnchor.constraint(equalToConstant: 44),
            
            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            loginButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func bind() {
        emailTextField.rx.text.orEmpty
            .bind(to: emailInputText)
            .disposed(by: disposeBag)
        
        emailInputText
            .map(checkEmailValid)
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        
        emailValid
            .subscribe { b in
                self.loginButton.isEnabled = b
            }
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: pwInputText)
            .disposed(by: disposeBag)
    }
    
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
}
