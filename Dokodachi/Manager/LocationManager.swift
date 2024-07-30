//
//  LocationManager.swift
//  Dokodachi
//
//  Created by 심관혁 on 7/3/24.
//

import CoreLocation
import RxSwift

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    var locationManager: CLLocationManager!
    private let locationSubject = PublishSubject<CLLocation>()
    
    var locationObservable: Observable<CLLocation> {
        return locationSubject.asObservable()
    }
    
    override init() {
        super.init()
        locationManager = CLLocationManager()
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
    
    func sendLoacation(username: String) {
        print("<<LocationManager의 sendLoaction 호출>>")
        
        let latitude = locationManager.location?.coordinate.latitude
        let longitude = locationManager.location?.coordinate.longitude
        let locationMessage = Message(text: "위치 공유", isIncoming: false, username: username, time: Date(), latitude: latitude, longitude: longitude)
        SocketIOManager.shared.sendMessage(username: username, message: locationMessage)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationSubject.onNext(location)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        print("Location Error: \(error)")
    }
    
}
