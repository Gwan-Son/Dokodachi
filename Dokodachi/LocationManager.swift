//
//  LocationManager.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/3/24.
//

import CoreLocation
import RxSwift

class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    private let locationSubject = PublishSubject<CLLocation>()
    
    var locationObservable: Observable<CLLocation> {
        return locationSubject.asObservable()
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationSubject.onNext(location)
            // Send location to the server using Socket.IO
            SocketIOManager.shared.sendLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
}
