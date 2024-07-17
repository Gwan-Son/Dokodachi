//
//  ChatMessageCell.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/8/24.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    let usernameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let bubbleBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
//    var usernameLeadingConstraint: NSLayoutConstraint!
    var usernameTopConstraint: NSLayoutConstraint!
    var messageTopConstraint: NSLayoutConstraint!
    
//    var isIncoming: Bool = true {
//        didSet {
//            bubbleBackgroundView.backgroundColor = isIncoming ? .white : .yellow
//            messageLabel.textColor = .black
//            
//            leadingConstraint.isActive = isIncoming
//            trailingConstraint.isActive = !isIncoming
//            usernameLeadingConstraint.isActive = isIncoming
//            usernameLabel.isHidden = !isIncoming
//        }
//    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubbleBackgroundView)
        contentView.addSubview(messageLabel)
    }
    
//    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//        
//        backgroundColor = .clear
//        
//        bubbleBackgroundView.backgroundColor = .yellow
//        bubbleBackgroundView.layer.cornerRadius = 12
//        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(bubbleBackgroundView)
//        
//        messageLabel.numberOfLines = 0
//        messageLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(messageLabel)
//        
//        usernameLabel.font = .systemFont(ofSize: 14)
//        usernameLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(usernameLabel)
//        
//        // TODO: - 내가 보낸 메시지와 상대가 보낸 메시지의 constraint를 따로 만들어서 active
//        
//        oppositeConstraint = [ // 상대 메시지
//            usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
//            usernameLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 0),
//            
//            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32),
//            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
//            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
//            
//            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
//            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -8),
//            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
//            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8),
//        ]
//        
////        myConstraint = [ // 내 메시지
////            /*
////             usernameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 0),
////             usernameLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 0),
////             
////             messageLabel.topAnchor.constraint(equalTo: usernameLabel.bottomAnchor, constant: 16),
////             */
////            
////            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
////            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
////            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
////            
////            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8),
////            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -8),
////            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8),
////            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8),
////        ]
//        
//        NSLayoutConstraint.activate(oppositeConstraint)
//        
//        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
//        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
//        usernameLeadingConstraint = usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
//
//    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.removeFromSuperview()
        messageTopConstraint.isActive = false
        usernameTopConstraint?.isActive = false
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
    }
    
    func configure(with message: Message) {
        backgroundColor = .gray
        messageLabel.text = message.text
        bubbleBackgroundView.backgroundColor = message.isIncoming ? .white : .yellow
        messageLabel.textColor = .black
        
        if message.isIncoming {
            usernameLabel.text = message.username
            contentView.addSubview(usernameLabel)
            usernameTopConstraint = usernameLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0)
            usernameTopConstraint.isActive = true
            usernameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32).isActive = true
            usernameLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.topAnchor, constant: 0).isActive = true
            messageTopConstraint = messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 32)
            leadingConstraint =  messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
            leadingConstraint.isActive = true
        } else {
            messageTopConstraint = messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
            trailingConstraint =  messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
            trailingConstraint.isActive = true
        }
        messageTopConstraint.isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8).isActive = true
        bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -8).isActive = true
        bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
        bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8).isActive = true
        
//        leadingConstraint = bubbleBackgroundView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 32)
//        trailingConstraint = bubbleBackgroundView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -32)
//                
//        if message.isIncoming {
//            leadingConstraint.isActive = true
//            trailingConstraint.isActive = false
//        } else {
//            leadingConstraint.isActive = false
//            trailingConstraint.isActive = true
//        }
        
        //TODO: - MessageLabel의 leading과 trailing은 isIncoming에 따라 수정되어야함.
//        messageLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: 16).isActive = true
//        messageLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: -16).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


