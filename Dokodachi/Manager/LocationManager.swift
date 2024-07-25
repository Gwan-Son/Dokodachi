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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func requestLocationPermission() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startLocationUpdates() {
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationSubject.onNext(location)
            print("Latitude: \(location.coordinate.latitude), Longitude: \(location.coordinate.longitude)")
            // Send location to the server using Socket.IO
//            SocketIOManager.shared.sendLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location Error: \(error)")
    }
}
