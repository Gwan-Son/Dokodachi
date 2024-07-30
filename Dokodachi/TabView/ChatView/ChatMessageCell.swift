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
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let bubbleBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let mapButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("위치 보기", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var usernameTopConstraint: NSLayoutConstraint!
    var messageTopConstraint: NSLayoutConstraint!
    var timeLeading: NSLayoutConstraint!
    var timeTrailing: NSLayoutConstraint!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(bubbleBackgroundView)
        contentView.addSubview(messageLabel)
        contentView.addSubview(timeLabel)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.removeFromSuperview()
        mapButton.removeFromSuperview()
        messageTopConstraint.isActive = false
        usernameTopConstraint?.isActive = false
        leadingConstraint?.isActive = false
        trailingConstraint?.isActive = false
        timeLeading?.isActive = false
        timeTrailing?.isActive = false
    }
    
    func configure(with message: Message) {
        backgroundColor = .gray
        messageLabel.text = message.text
        bubbleBackgroundView.backgroundColor = message.isIncoming ? .white : .yellow
        messageLabel.textColor = .black
        mapButton.addTarget(self, action: #selector(mapButtonTapped), for: .touchUpInside)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        timeLabel.text = dateFormatter.string(from: message.time)
        
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
            timeLeading = timeLabel.leadingAnchor.constraint(equalTo: bubbleBackgroundView.trailingAnchor, constant: 10)
            timeLeading.isActive = true
        } else {
            messageTopConstraint = messageLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16)
            trailingConstraint =  messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
            trailingConstraint.isActive = true
            timeTrailing = timeLabel.trailingAnchor.constraint(equalTo: bubbleBackgroundView.leadingAnchor, constant: -10)
            timeTrailing.isActive = true
        }
        messageTopConstraint.isActive = true
        messageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16).isActive = true
        messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -8).isActive = true
        bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -8).isActive = true
        bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
        bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 8).isActive = true
        timeLabel.bottomAnchor.constraint(equalTo: bubbleBackgroundView.bottomAnchor, constant: 0).isActive = true
        
        if message.latitude == nil || message.longitude == nil {
            print("mapButton 안생겼어!!")
        } else {
            print("mapButton 생겼어!!!")
            contentView.addSubview(mapButton)
            mapButton.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 4).isActive = true
            mapButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8).isActive = true
            mapButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
            mapButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
            mapButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        }
        
        // TODO: - 위치 공유와 일반 메시지 구분해야함
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func mapButtonTapped() {
        print("mapButton Tapped")
    }
}
