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
    
    public func congifure(text: String, placeholder: String) {
        passwordLabel.text = text
        passwordTextField.placeholder = placeholder
        
        passwordLabel.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(passwordLabel)
        contentView.addSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            passwordLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            passwordLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            passwordTextField.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
}
