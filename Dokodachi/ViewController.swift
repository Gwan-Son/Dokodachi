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

    var idField: UITextField!
    var pwField: UITextField!
    var loginButton: UIButton!
    var idValidView: UIView!
    var pwValidView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // idField
        idField = UITextField()
        idField.placeholder = "id를 입력해주세요."
        idField.translatesAutoresizingMaskIntoConstraints = false
        idField.font = UIFont.systemFont(ofSize: 18)
        idField.textColor = .black
        view.addSubview(idField)
        
        // pwField
        pwField = UITextField()
        pwField.placeholder = "pw를 입력해주세요."
        pwField.translatesAutoresizingMaskIntoConstraints = false
        pwField.font = UIFont.systemFont(ofSize: 18)
        pwField.textColor = .black
        view.addSubview(pwField)
        
        // loginButton
        loginButton = UIButton()
        loginButton.setTitle("로그인", for: .normal)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loginButton)
        
        // idValidView
        idValidView = UIView()
        idValidView.backgroundColor = .red
        idValidView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(idValidView)
        
        // pwValidView
        pwValidView = UIView()
        pwValidView.backgroundColor = .red
        pwValidView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pwValidView)
        
        NSLayoutConstraint.activate([
            idField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            idField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pwField.topAnchor.constraint(equalTo: idField.topAnchor, constant: 20),
            pwField.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }


}

// ChatViewModel
// 

