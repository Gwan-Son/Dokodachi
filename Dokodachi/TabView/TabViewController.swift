//
//  HomeViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/20/24.
//

import UIKit

class TabViewController: UITabBarController {
    
    var username: String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        setTabbar()
        setAttribute()
    }
    
    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTabbar() {
        let appearanceTabbar = UITabBarAppearance()
        appearanceTabbar.configureWithOpaqueBackground()
        appearanceTabbar.backgroundColor = .white
        tabBar.standardAppearance = appearanceTabbar
        tabBar.tintColor = .black
        tabBar.backgroundColor = .white
    }
    
    func setAttribute() {
        viewControllers = [
            setupViewController(for: HomeViewController(), with: "홈", image: UIImage(systemName: "house")!, selectedImage: UIImage(systemName: "house.fill")!),
            setupViewController(for: ChatViewController(username: username), with: "채팅", image: UIImage(systemName: "message")!, selectedImage: UIImage(systemName: "message.fill")!),
            setupViewController(for: MapViewController(username: username), with: "지도", image: UIImage(systemName: "map")!, selectedImage: UIImage(systemName: "map.fill")!),
            setupViewController(for: SettingViewController(), with: "설정", image: UIImage(systemName: "gearshape")!, selectedImage: UIImage(systemName: "gearshape.fill")!)
            
        ]
    }
    
    private func setupViewController(for rootViewController: UIViewController, with title: String, image: UIImage, selectedImage: UIImage) -> UIViewController {
        let VC = UINavigationController(rootViewController: rootViewController)
        VC.navigationBar.isTranslucent = false
        VC.navigationBar.backgroundColor = .white
        VC.tabBarItem.title = title
        VC.tabBarItem.image = image
        VC.tabBarItem.selectedImage = selectedImage
        VC.interactivePopGestureRecognizer?.delegate = nil
        VC.navigationBar.isHidden = true
        return VC
    }
}
