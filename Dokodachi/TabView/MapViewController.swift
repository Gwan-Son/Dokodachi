//
//  MapViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/22/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
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
        
        let mapView = NMFNaverMapView(frame: view.frame)
        mapView.mapView.positionMode = .direction
        mapView.showLocationButton = true
        mapView.mapView.touchDelegate = self
        
        // 지도를 현재 위치로 이동하는 코드
        let cameraPosition = mapView.mapView.cameraPosition
        cameraPosition.target.lat = (locationManager.locationManager.location?.coordinate.latitude)!
        cameraPosition.target.lng = (locationManager.locationManager.location?.coordinate.longitude)!
        mapView.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition))
        
        view.addSubview(mapView)
    }
    
}

extension MapViewController: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        print("Lat: \(latlng.lat), Lon: \(latlng.lng)")
        
        let alert = UIAlertController(title: "위치 공유", message: "현재 위치를 공유하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            // Alert에서 확인을 누르면 위치 공유
            self?.locationManager.sendLoacation(username: self!.username)
            // 채팅 탭뷰로 이동하는 코드
            if let tabBarController = self?.tabBarController {
                tabBarController.selectedIndex = 1
            }
            
        }
        alert.addAction(okAction)
        alert.addAction(.init(title: "취소", style: .destructive))
        present(alert, animated: true)
    }
}
