//
//  MapViewController.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/22/24.
//

import UIKit
import NMapsMap

class MapViewController: UIViewController {
    
    let locationManager = LocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestLocationPermission()
        locationManager.startLocationUpdates()
        let mapView = NMFMapView(frame: view.frame)
        mapView.positionMode = .direction
        
        let locationOverlay = mapView.locationOverlay
        locationOverlay.hidden = false
        locationOverlay.circleRadius = 50
        
        view.addSubview(mapView)
    }
    
}
