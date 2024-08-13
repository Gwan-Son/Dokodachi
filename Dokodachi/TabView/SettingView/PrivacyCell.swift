//
//  PrivacyCell.swift
//  Dokodachi
//
//  Created by 심관혁 on 8/8/24.
//

import UIKit

class PrivacyCell: UITableViewCell {
    let passwordLabel = UILabel()
    let passwordTextField = UITextField()
    let eyeButton = UIButton()
    let buttonLabel = UILabel()
    var secureText: Bool = true
    
    public func congifure(text: String, placeholder: String) {
        passwordLabel.text = text
        passwordTextField.placeholder = placeholder
        passwordTextField.isSecureTextEntry = true
        eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(.gray, renderingMode: .alwaysOriginal), for: .normal)
        eyeButton.addTarget(self, action: #selector(eyeButtonTapped), for: .touchUpInside)
        
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        eyeButton.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(eyeButton)
        
        
        NSLayoutConstraint.activate([
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            passwordTextField.widthAnchor.constraint(greaterThanOrEqualToConstant: 100),
            passwordTextField.centerYAnchor.constraint(equalTo: centerYAnchor),
            eyeButton.leadingAnchor.constraint(equalTo: passwordTextField.trailingAnchor, constant: 5),
            eyeButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            eyeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func eyeButtonTapped() {
        secureText.toggle()
        passwordTextField.isSecureTextEntry = secureText
        if secureText {
            eyeButton.setImage(UIImage(systemName: "eye")?.withTintColor(.gray, renderingMode: .alwaysOriginal), for: .normal)
        } else {
            eyeButton.setImage(UIImage(systemName: "eye.slash")?.withTintColor(.gray, renderingMode: .alwaysOriginal), for: .normal)
        }
    }
    
    public func buttonConfigure() {
        buttonLabel.text = "저장"
        buttonLabel.font = UIFont.systemFont(ofSize: 18)
        buttonLabel.textColor = UIColor(hexCode: "7E8EF1")
        buttonLabel.textAlignment = .center
        
        buttonLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonLabel)
        
        NSLayoutConstraint.activate([
            buttonLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            buttonLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
