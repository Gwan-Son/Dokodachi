//
//  ViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 6/21/24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    let idInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let idValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    let pwInputText: BehaviorSubject<String> = BehaviorSubject(value: "")
    let pwValid: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    var idField: UITextField!
    var pwField: UITextField!
    var loginButton: UIButton!
    var idValidView: UIView!
    var pwValidView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // idField
        idField = UITextField()
        idField.borderStyle = .roundedRect
        idField.placeholder = "id를 입력해주세요."
        idField.translatesAutoresizingMaskIntoConstraints = false
        idField.font = UIFont.systemFont(ofSize: 18)
        idField.textColor = .black
        view.addSubview(idField)
        
        // pwField
        pwField = UITextField()
        pwField.borderStyle = .roundedRect
        pwField.placeholder = "pw를 입력해주세요."
        pwField.translatesAutoresizingMaskIntoConstraints = false
        pwField.font = UIFont.systemFont(ofSize: 18)
        pwField.textColor = .black
        view.addSubview(pwField)
        
        // loginButton
        loginButton = UIButton()
        loginButton.setTitle("Login", for: .normal)
        loginButton.setTitle("Fill the Fields", for: .disabled)
        loginButton.isEnabled = false
        loginButton.layer.cornerRadius = 10
        loginButton.backgroundColor = .tintColor
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // idValidView
        idValidView = UIView()
        idValidView.backgroundColor = .red
        idValidView.translatesAutoresizingMaskIntoConstraints = false
        idValidView.layer.cornerRadius = 5
        idValidView.clipsToBounds = true
        view.addSubview(idValidView)
        
        // pwValidView
        pwValidView = UIView()
        pwValidView.backgroundColor = .red
        pwValidView.translatesAutoresizingMaskIntoConstraints = false
        pwValidView.layer.cornerRadius = 5
        pwValidView.clipsToBounds = true
        view.addSubview(pwValidView)
        
        NSLayoutConstraint.activate([
            idField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            idField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            idField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            pwField.topAnchor.constraint(equalTo: idField.bottomAnchor, constant: 20),
            pwField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pwField.leadingAnchor.constraint(equalTo: view.leadingAnchor,constant: 30),
            loginButton.topAnchor.constraint(equalTo: pwField.bottomAnchor, constant: 20),
            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            idValidView.widthAnchor.constraint(equalToConstant: 10),
            idValidView.heightAnchor.constraint(equalToConstant: 10),
            idValidView.leadingAnchor.constraint(equalTo: idField.trailingAnchor, constant: -20),
            idValidView.centerYAnchor.constraint(equalTo: idField.centerYAnchor),
            pwValidView.widthAnchor.constraint(equalToConstant: 10),
            pwValidView.heightAnchor.constraint(equalToConstant: 10),
            pwValidView.leadingAnchor.constraint(equalTo: pwField.trailingAnchor, constant: -20),
            pwValidView.centerYAnchor.constraint(equalTo: pwField.centerYAnchor)
            
        ])
        bindInput()
        bindOutput()
    }
    
    private func bindInput() {
        // input
        idField.rx.text.orEmpty
            .bind(to: idInputText)
            .disposed(by: disposeBag)
        
        idInputText
            .map(checkEmailValid)
            .bind(to: idValid)
            .disposed(by: disposeBag)
        
        pwField.rx.text.orEmpty
            .bind(to: pwInputText)
            .disposed(by: disposeBag)
        
        pwInputText
            .map(checkPasswordValid)
            .bind(to: pwValid)
            .disposed(by: disposeBag)
    }
    
    private func bindOutput() {
        // output
        idValid.subscribe(onNext: {b in self.idValidView.isHidden = b})
            .disposed(by: disposeBag)
        
        pwValid.subscribe(onNext: { b in self.pwValidView.isHidden = b})
            .disposed(by: disposeBag)
        
        Observable.combineLatest(idValid, pwValid, resultSelector: { $0 && $1})
            .subscribe(onNext: { b in
                self.loginButton.isEnabled = b
            })
            .disposed(by: disposeBag)
    }
    
    
    private func checkEmailValid(_ email: String) -> Bool {
        return email.contains("@") && email.contains(".")
    }
    
    private func checkPasswordValid(_ password: String) -> Bool {
        return password.count > 5
    }
    
    
    
}
