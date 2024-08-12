//
//  MapViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/22/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    let mapView = NMFNaverMapView()
    let shareButton = UIButton(type: .system)
    var cameraPosition: NMFCameraPosition?
    var marker: NMFMarker?
    var username: String
    
    let locationManager = LocationManager.shared
    
    init(username: String) {
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestLocationPermission()
        locationManager.startLocationUpdates()
        NotificationCenter.default.addObserver(self, selector: #selector(showLocation(_:)), name: NSNotification.Name("ShowLocation"), object: nil)
        
        mapView.mapView.positionMode = .direction
        mapView.showLocationButton = true
        mapView.mapView.touchDelegate = self
        
        shareButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        shareButton.tintColor = .green
        shareButton.backgroundColor = .white
        shareButton.layer.cornerRadius = 25
        shareButton.layer.frame.size = CGSize(width: 50, height: 50)
        shareButton.addTarget(self, action: #selector(shareLocation), for: .touchUpInside)
        
        
        // 지도를 현재 위치로 이동하는 코드
        cameraPosition = mapView.mapView.cameraPosition
        cameraPosition!.target.lat = (locationManager.locationManager.location?.coordinate.latitude)!
        cameraPosition!.target.lng = (locationManager.locationManager.location?.coordinate.longitude)!
        mapView.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition!))
        
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            shareButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            shareButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            shareButton.widthAnchor.constraint(equalToConstant: 50),
            shareButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // 위치 공유 버튼 눌렀을 때 카메라 이동
    func viewLocation(latitude: Double, longitude: Double) {
        cameraPosition?.target.lat = latitude
        cameraPosition?.target.lng = longitude
        mapView.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition!))
    }
    
    func createMarker(username: String, lat: Double, lng: Double) {
        marker = NMFMarker()
        marker?.position = NMGLatLng(lat: lat, lng: lng)
        marker?.captionText = username
        marker?.captionAligns = [NMFAlignType.top]
        marker?.captionOffset = 15
        marker?.captionTextSize = 16
        marker?.touchHandler = handler
        marker?.iconTintColor = randomColor() // 마커 랜덤 색상 지정
        marker?.mapView = mapView.mapView
    }
    
    // 마커 랜덤 색상
    func randomColor() -> UIColor {
        let red = CGFloat(arc4random_uniform(256)) / 255.0
        let green = CGFloat(arc4random_uniform(256)) / 255.0
        let blue = CGFloat(arc4random_uniform(256)) / 255.0
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // 마커 터치 핸들러
    lazy var handler: NMFOverlayTouchHandler = { [weak self] (overlay) -> Bool in
        guard let self = self else { return false }
        print("마커 \(overlay.userInfo["tag"] ?? "tag") 터치됨")
        self.deleteMarker(marker: overlay)
        return true
    }
    
    // 마커 삭제
    func deleteMarker(marker: NMFOverlay) {
        let alert = UIAlertController(title: "마커 삭제", message: "해당 마커를 삭제하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            marker.mapView = nil
        }
        alert.addAction(okAction)
        alert.addAction(.init(title: "취소", style: .destructive))
        self.present(alert, animated: true)
    }
    
    // 채팅에서 위치보기 버튼을 눌렀을 때
    @objc private func showLocation(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let latitude = userInfo["latitude"] as? Double,
              let longitude = userInfo["longitude"] as? Double,
              let username = userInfo["username"] as? String else { return }
        viewLocation(latitude: latitude, longitude: longitude)
        createMarker(username: username, lat: latitude, lng: longitude)
    }
    
    // 위치 공유 버튼
    @objc private func shareLocation() {
        let alert = UIAlertController(title: "위치 공유", message: "현재 위치를 공유하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.locationManager.sendLoacation(username: self!.username)
            if let tabBarController = self?.tabBarController {
                tabBarController.selectedIndex = 0
            }
        }
        alert.addAction(okAction)
        alert.addAction(.init(title: "취소", style: .destructive))
        present(alert, animated: true)
    }
    
}

extension MapViewController: NMFMapViewTouchDelegate {
//    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
//        print("Lat: \(latlng.lat), Lon: \(latlng.lng)")
//        
//        let alert = UIAlertController(title: "위치 공유", message: "현재 위치를 공유하시겠습니까?", preferredStyle: .alert)
//        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
//            // Alert에서 확인을 누르면 위치 공유
//            self?.locationManager.sendLoacation(username: self!.username)
//            // 채팅 탭뷰로 이동하는 코드
//            if let tabBarController = self?.tabBarController {
//                tabBarController.selectedIndex = 1
//            }
//            
//        }
//        alert.addAction(okAction)
//        alert.addAction(.init(title: "취소", style: .destructive))
//        present(alert, animated: true)
//    }
    
}

