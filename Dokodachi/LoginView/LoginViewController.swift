//
//  LoginViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/18/24.
//

import UIKit
import FirebaseAuth
import FirebaseCore
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let emailInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let emailValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let pwInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let pwValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    
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
        textField.textContentType = .oneTimeCode
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
    
    let registerButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
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
        
        //rx이전 selector
//        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        registerButton.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(registerButton)
        
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
            loginButton.heightAnchor.constraint(equalToConstant: 44),
            
            registerButton.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: 20),
            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
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
        
        passwordTextField.rx.text.orEmpty
            .bind(to: pwInputText)
            .disposed(by: disposeBag)
        
        pwInputText
            .map(checkPasswordValid)
            .bind(to: pwValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailValid, pwValid, resultSelector: { s1, s2 in s1 && s2})
            .subscribe { b in
                self.loginButton.isEnabled = b
            }
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let email = self?.emailTextField.text else {return}
                guard let pw = self?.passwordTextField.text else {return}
                
                Auth.auth().signIn(withEmail: email, password: pw) { result, error in
                    if result == nil {
                        print("login failed")
                        if let error = error {
                            print("error: \(error)")
                            let alert = UIAlertController(title: "로그인 실패", message: "이메일과 비밀번호를 확인해주세요", preferredStyle: .alert)
                            alert.addAction(.init(title: "확인", style: .default))
                            self!.present(alert, animated: true)
                        }
                    } else if result != nil {
                        print("login success")
                        let tabVC = TabViewController(username: self!.emailTextField.text!)
                        tabVC.modalPresentationStyle = .fullScreen
                        self!.present(tabVC, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func checkPasswordValid(_ password: String) -> Bool {
        let pattern = "^.*(?=^.{8,16}$)(?=.*\\d)(?=.*[a-zA-Z])(?=.*[!@#$%^&+=]).*$"
        let pred = NSPredicate(format: "SELF MATCHES %@", pattern)
        return pred.evaluate(with: password)
    }
    
    //rx이전 selector
//    @objc private func loginButtonTapped() {
//        guard let email = emailTextField.text else { return }
//        guard let pw = passwordTextField.text else { return }
//        
//        Auth.auth().signIn(withEmail: email, password: pw) { result, error in
//            if result == nil {
//                print("login failed")
//                if let error = error {
//                    print("error: \(error)")
//                    let alert = UIAlertController(title: "로그인 실패", message: "이메일과 비밀번호를 확인해주세요", preferredStyle: .alert)
//                    alert.addAction(.init(title: "확인", style: .default))
//                    self.present(alert, animated: true)
//                }
//            } else if result != nil {
//                print("login success")
////                let chatVC = ChatViewController(username: self.emailTextField.text!)
////                self.navigationController?.pushViewController(chatVC, animated: true)
//                let tabVC = TabViewController(username: self.emailTextField.text!)
//                tabVC.modalPresentationStyle = .fullScreen
//                self.present(tabVC, animated: true)
//            }
//        }
//    }
    
    @objc private func registerButtonTapped() {
        let registerVC = RegisterViewController()
        self.navigationController?.pushViewController(registerVC, animated: true)
    }
}
