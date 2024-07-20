//
//  HomeViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/20/24.
//

import UIKit

class HomeViewController: UIViewController {
    
    let tabBar: UITabBar = {
        let bar = UITabBar()
        return bar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(tabBar)
    }
}
