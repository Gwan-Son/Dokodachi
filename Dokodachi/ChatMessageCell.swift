//
//  ChatMessageCell.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/8/24.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    let usernameLabel = UILabel()
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var usernameLeadingConstraint: NSLayoutConstraint!
    
    var isIncoming: Bool = true {
        didSet {
            bubbleBackgroundView.backgroundColor = isIncoming ? .white : .yellow
            messageLabel.textColor = .black
            
            leadingConstraint.isActive = isIncoming
            trailingConstraint.isActive = !isIncoming
            usernameLeadingConstraint.isActive = isIncoming
            usernameLabel.isHidden = !isIncoming
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = .clear
        
        bubbleBackgroundView.backgroundColor = .yellow
        bubbleBackgroundView.layer.cornerRadius = 12
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleBackgroundView)
        
        messageLabel.numberOfLines = 0
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(messageLabel)
        
        usernameLabel.font = .systemFont(ofSize: 14)
        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(usernameLabel)
        
        let constraints = [
            /*
             usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
             usernameLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 0),
             
             messageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
             */
            usernameLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 0),
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -8),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        usernameLeadingConstraint = usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


