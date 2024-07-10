//
//  ChatMessageCell.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/8/24.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    let messageLabel = UILabel()
    var isIncoming: Bool = false {
        didSet {
            updateUI()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageLabel)
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            messageLabel.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75)
        ])
        
        updateUI()
    }
    
    private func updateUI() {
        if isIncoming {
            messageLabel.textAlignment = .left
            messageLabel.textColor = .black
            messageLabel.backgroundColor = UIColor(white: 0.9, alpha: 1)
            messageLabel.layer.cornerRadius = 8
            messageLabel.layer.masksToBounds = true
        } else {
            messageLabel.textAlignment = .right
            messageLabel.textColor = .white
            messageLabel.backgroundColor = UIColor.blue
            messageLabel.layer.cornerRadius = 8
            messageLabel.layer.masksToBounds = true
        }
    }
}

