# Dokodachi
Socket.IO를 통한 실시간 채팅과 지도에서의 위치 공유 어플리케이션

~~일본어의 "어디"를 뜻하는 도코(どこ)와 "친구"를 뜻하는 토모다치(友達)를 결합하여 도코다치~~

## 목차
- [🚀 개발 기간](#-개발-기간)
- [💻 개발 환경](#-개발-환경)
- [👀 미리 보기](#-미리보기)
- [🔐 Firebase 회원가입 및 로그인](#-firebase-회원가입-및-로그인)
- [🌐 RxSwift를 통한 비동기 처리](#-rxswift를-통한-비동기-처리)
- [📡 Socket.IO를 이용한 소켓프로그래밍](#-socket.io를-이용한-소켓프로그래밍)
- [🗺️ 네이버 지도 API](#-네이버-지도-api)
- [📁 파일 구조](#-파일-구조)

---

# 🚀 개발 기간
24.07.05 ~ 24.08.13 (약 1개월)

# 💻 개발 환경
- `XCode 15.4`
- `Swift 5.9.2`

<p align="center" width="100%">
 <img src="https://github.com/user-attachments/assets/dde8f9d7-cf0a-4c9a-8d0c-838f9a8da1ca" width="30%">
 <img src="https://github.com/user-attachments/assets/f401c0fb-049a-49a6-a65b-9c24ddb52f5b" width="30%">
 <img src="https://github.com/user-attachments/assets/553d44d0-df00-4d76-a61c-5bf76185c442" width="30%">
</p>

# 👀 미리보기
![채팅](https://github.com/user-attachments/assets/baabcfb3-0d84-4054-852d-aed6cf077d6a)


# 🔐 Firebase 회원가입 및 로그인
소켓 프로그래밍으로 실시간 채팅을 구현하기 이전에 채팅에 참여하는 사용자를 구분하는 것이 중요하다고 생각했습니다. 그래서 firebase를 통해 회원가입 및 로그인을 할 수 있게 세팅하였습니다.(google firebase 공식 문서 참고)

회원가입 코드
```
//registerViewController.swift
    @objc func registerButtonTapped() {
        guard let email = emailTextField.text else { return }
        guard let pw = passwordTextField.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: pw) { result, error in
            if let error = error {
                print("Error: \(error)")
            }
            
            if let result = result {
                print("result: \(result)")
                let alert = UIAlertController(title: "회원가입 완료", message: "회원가입이 완료되었습니다.", preferredStyle: .alert)
                let okButton = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
                    self?.dismiss(animated: true)
                }
                alert.addAction(okButton)
                self.present(alert, animated: true)
            }
        }
    }
```

# 🌐 RxSwift를 통한 비동기 처리
이전 프로젝트에서 사용했던 Combine과 유사한 기능을 가지고 있지만 RxSwift는 내장 라이브러리가 아니기 때문에 cocoaPods을 이용하여 import해주었습니다. RxSwift는 Combine에 비해 더 세부적인 기능을 가지고 있어 학습하는 데에 있어 시간이 굉장히 많이 소요되었습니다. 해당 프로젝트에서 Rx를 사용한 파트는 로그인 및 회원가입입니다. 사용자의 이메일과 비밀번호를 비동기적 처리를 하여 textField에 입력을 하였을 때 이메일 형식과 비밀번호 규칙에 맞는지에 따라 로그인 및 회원가입 버튼을 활성화 했습니다.
```
//LoginViewController.swift
private func bind() {
        emailTextField.rx.text.orEmpty
            .bind(to: emailInputText)
            .disposed(by: disposeBag)
        
        emailInputText
            .map(checkEmailValid)
            .bind(to: emailValid)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: pwInputText)
            .disposed(by: disposeBag)
        
        pwInputText
            .map(checkPasswordValid)
            .bind(to: pwValid)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(emailValid, pwValid, resultSelector: { s1, s2 in s1 && s2})
            .subscribe { b in
                self.loginButton.isEnabled = b
            }
            .disposed(by: disposeBag)
        
        loginButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let email = self?.emailTextField.text else {return}
                guard let pw = self?.passwordTextField.text else {return}
                
                Auth.auth().signIn(withEmail: email, password: pw) { result, error in
                    if result == nil {
                        print("login failed")
                        if let error = error {
                            print("error: \(error)")
                            let alert = UIAlertController(title: "로그인 실패", message: "이메일과 비밀번호를 확인해주세요", preferredStyle: .alert)
                            alert.addAction(.init(title: "확인", style: .default))
                            self!.present(alert, animated: true)
                        }
                    } else if result != nil {
                        print("login success")
                        let tabVC = TabViewController(username: self!.emailTextField.text!)
                        tabVC.modalPresentationStyle = .fullScreen
                        self!.present(tabVC, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
}
```

# 📡 Socket.IO를 이용한 소켓프로그래밍
실시간 채팅을 구현하기 위해선 네트워크 소켓과 클라이언트 소켓이 필요했습니다. 그래서 node.js에서 Socket.IO를 이용하여 네트워크 소켓을 생성하였습니다.
```
// server.js
// 해당 프로젝트는 배포 목적이 없기 때문에 로컬환경에서 진행하였습니다.
const express = require('express');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

io.on('connection', (socket) => {
    console.log(`A user connected: ${socket.id}`);

    // Listen for incoming messages
    socket.on('chat message', (data) => {
        console.log(`Message received from : ${socket.id}`, data);
        socket.broadcast.emit("chat message", data);
    });

    // Listen for incoming locations
    socket.on('send location', (data) => {
        console.log(`Location received from : ${socket.id}`, data);
        io.emit("send location", data);
    });

    // Handle user disconnect
    socket.on('disconnect', (reason) => {
        console.log(`User disconnected: ${socket.id}, Reason: ${reason}`);
    });
});

const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
```

클라이언트 소켓은 cocoaPods을 이용하여 Socket.IO를 import해주었고, SocketIOManager.swift를 생성하여 소켓을 따로 관리할 수 있게 하였습니다.
```
//SocketIOManager.swift
(생략)
        socket.on(clientEvent: .connect) {data, ack in
            print("Socket connected")
        }
        
        socket.on("chat message") { [weak self] (dataArray, ack) in
            guard let messageData = dataArray.first as? [String: Any] else { return }
            self?.messageObservable.onNext(messageData)
        }
        
        socket.on("send location") { [weak self] (dataArray, ack) in
            guard let locationData = dataArray.first as? [String: Any] else { return }
            self?.messageObservable.onNext(locationData)
        }
(생략)
```
클라이언트 소켓은 메시지와 위치정보를 네트워크 소켓으로 보낼 수 있는 기능을 가지고 있고, 네트워크 소켓은 클라이언트로부터 받은 정보를 io.emit과 socket.broadcast.emit을 통하여 다른 클라이언트에게 보내게 됩니다.
- io.emit과 socket.broadcast.emit을 나눈 이유
ChatViewController에서 네트워크 소켓으로 채팅을 보내면 tableViewCell에 Rx를 이용하여 메시지가 추가됩니다. 하지만 io.emit을 사용하면 자신을 포함한 모든 유저에게 메시지가 전송되기 때문에 메시지 중복이 발생합니다. 그래서 sendMessage 메서드를 사용할 땐 socket.broadcast.emit을 사용하여 본인을 제외한 다른 유저들에게 메시지를 보낼 수 있게 하였습니다. 하지만 MapViewController에서 위치 공유 버튼을 누르게 되면 ChatViewController에서 보낸게 아니기 때문에 tableViewCell에 추가되지 않습니다. 그래서 모든 유저들에게 메시지를 보내는 io.emit을 사용하여 자신에게도 메시지가 추가되게끔 하였습니다.

# 🗺️ 네이버 지도 API
네이버 지도 API를 통해 NMFNaverMapView()를 생성해주었습니다. 지도뷰가 처음 실행될 때 사용자의 위치정보를 기반으로 현위치로 카메라가 이동할 수 있게 설정하였습니다.
```
//MapViewController.swift
// 지도를 현재 위치로 이동하는 코드
        cameraPosition = mapView.mapView.cameraPosition
        cameraPosition!.target.lat = (locationManager.locationManager.location?.coordinate.latitude)!
        cameraPosition!.target.lng = (locationManager.locationManager.location?.coordinate.longitude)!
        mapView.mapView.moveCamera(NMFCameraUpdate(position: cameraPosition!))
```
사용자의 편의성을 위해 오른 엄지로 쉽게 누를 수 있게 우측 하단에 별도의 버튼을 생성하여 위치공유를 할 수 있는 버튼을 생성하였습니다. 그리고 채팅뷰에서 위치보기 버튼을 누르게 되면 해당하는 좌표에 NMFMarker()를 생성하여 카메라 이동과 함께 지도에 표시하였습니다.
```
//MapViewController.swift
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
```

# 📁 파일 구조
```
.
├── Dokodachi
│   ├── AppDelegate.swift
│   ├── Assets.xcassets
│   │   ├── AccentColor.colorset
│   │   │   └── Contents.json
│   │   ├── AppIcon.appiconset
│   │   │   └── Contents.json
│   │   └── Contents.json
│   ├── Base.lproj
│   │   └── LaunchScreen.storyboard
│   ├── Extension
│   │   └── Color+Extension.swift
│   ├── GoogleService-Info.plist
│   ├── Info.plist
│   ├── LoginView
│   │   ├── LoginViewController.swift
│   │   └── RegisterViewController.swift
│   ├── Manager
│   │   ├── LocationManager.swift
│   │   └── SocketIOManager.swift
│   ├── Model
│   │   └── MessageModel.swift
│   ├── SceneDelegate.swift
│   └── TabView
│       ├── ChatView
│       │   ├── ChatMessageCell.swift
│       │   ├── ChatMessageCellDelegate.swift
│       │   ├── ChatViewController.swift
│       │   └── ChatViewModel.swift
│       ├── MapViewController.swift
│       ├── SettingView
│       │   ├── AccountViewController.swift
│       │   ├── HelpViewController.swift
│       │   ├── PrivacyCell.swift
│       │   ├── PrivacyViewController.swift
│       │   └── SettingViewController.swift
│       └── TabViewController.swift
├── Dokodachi.xcodeproj
│   ├── project.pbxproj
│   ├── project.xcworkspace
│   │   ├── contents.xcworkspacedata
│   │   ├── xcshareddata
│   │   │   ├── IDEWorkspaceChecks.plist
│   │   │   └── swiftpm
│   │   │       └── configuration
│   │   └── xcuserdata
│   │       └── simgwanhyeok.xcuserdatad
│   │           └── UserInterfaceState.xcuserstate
│   └── xcuserdata
│       └── simgwanhyeok.xcuserdatad
│           └── xcschemes
│               └── xcschememanagement.plist
├── Dokodachi.xcworkspace
│   ├── contents.xcworkspacedata
│   ├── xcshareddata
│   │   ├── IDEWorkspaceChecks.plist
│   │   └── swiftpm
│   │       ├── Package.resolved
│   │       └── configuration
│   └── xcuserdata
│       └── simgwanhyeok.xcuserdatad
│           ├── UserInterfaceState.xcuserstate
│           └── xcschemes
│               └── xcschememanagement.plist
├── DokodachiTests
│   └── DokodachiTests.swift
├── DokodachiUITests
│   ├── DokodachiUITests.swift
│   └── DokodachiUITestsLaunchTests.swift
├── Podfile
├── Podfile.lock
├── Pods
│   ├── Headers
│   ├── Local Podspecs
│   ├── Manifest.lock
│   ├── NMapsGeometry
│   │   ├── LICENSE
│   │   └── framework
│   │       └── NMapsGeometry.xcframework
│   │           ├── Info.plist
│   │           ├── ios-arm64
│   │           │   └── NMapsGeometry.framework
│   │           │       ├── Headers
│   │           │       │   ├── NMGBounds.h
│   │           │       │   ├── NMGConstants.h
│   │           │       │   ├── NMGGeometry.h
│   │           │       │   ├── NMGLatLng.h
│   │           │       │   ├── NMGLatLngBounds.h
│   │           │       │   ├── NMGLineString.h
│   │           │       │   ├── NMGMultiPolygon.h
│   │           │       │   ├── NMGPoint.h
│   │           │       │   ├── NMGPolygon.h
│   │           │       │   ├── NMGSegment.h
│   │           │       │   ├── NMGTm128.h
│   │           │       │   ├── NMGUtils.h
│   │           │       │   ├── NMGUtmk.h
│   │           │       │   ├── NMGWebMercatorCoord.h
│   │           │       │   └── NMapsGeometry.h
│   │           │       ├── Info.plist
│   │           │       ├── Modules
│   │           │       │   └── module.modulemap
│   │           │       ├── NMapsGeometry
│   │           │       └── PrivacyInfo.xcprivacy
│   │           └── ios-arm64_x86_64-simulator
│   │               └── NMapsGeometry.framework
│   │                   ├── Headers
│   │                   │   ├── NMGBounds.h
│   │                   │   ├── NMGConstants.h
│   │                   │   ├── NMGGeometry.h
│   │                   │   ├── NMGLatLng.h
│   │                   │   ├── NMGLatLngBounds.h
│   │                   │   ├── NMGLineString.h
│   │                   │   ├── NMGMultiPolygon.h
│   │                   │   ├── NMGPoint.h
│   │                   │   ├── NMGPolygon.h
│   │                   │   ├── NMGSegment.h
│   │                   │   ├── NMGTm128.h
│   │                   │   ├── NMGUtils.h
│   │                   │   ├── NMGUtmk.h
│   │                   │   ├── NMGWebMercatorCoord.h
│   │                   │   └── NMapsGeometry.h
│   │                   ├── Info.plist
│   │                   ├── Modules
│   │                   │   └── module.modulemap
│   │                   ├── NMapsGeometry
│   │                   ├── PrivacyInfo.xcprivacy
│   │                   └── _CodeSignature
│   │                       └── CodeResources
│   ├── NMapsMap
│   │   ├── LICENSE
│   │   └── framework
│   │       └── NMapsMap.xcframework
│   │           ├── Info.plist
│   │           ├── ios-arm64
│   │           │   └── NMapsMap.framework
│   │           │       ├── Assets.car
│   │           │       ├── Base.lproj
│   │           │       │   └── Foundation.strings
│   │           │       ├── Headers
│   │           │       │   ├── NMCBuilder.h
│   │           │       │   ├── NMCCluster.h
│   │           │       │   ├── NMCClusterMarkerInfo.h
│   │           │       │   ├── NMCClusterMarkerUpdater.h
│   │           │       │   ├── NMCClusterer.h
│   │           │       │   ├── NMCClustererUpdateCallback.h
│   │           │       │   ├── NMCClusteringKey.h
│   │           │       │   ├── NMCComplexBuilder.h
│   │           │       │   ├── NMCDefaultClusterMarkerUpdater.h
│   │           │       │   ├── NMCDefaultDistanceStrategy.h
│   │           │       │   ├── NMCDefaultLeafMarkerUpdater.h
│   │           │       │   ├── NMCDefaultMarkerManager.h
│   │           │       │   ├── NMCDefaultPositioningStrategy.h
│   │           │       │   ├── NMCDefaultTagMergeStrategy.h
│   │           │       │   ├── NMCDefaultThresholdStrategy.h
│   │           │       │   ├── NMCDistanceStrategy.h
│   │           │       │   ├── NMCLeaf.h
│   │           │       │   ├── NMCLeafMarkerInfo.h
│   │           │       │   ├── NMCLeafMarkerUpdater.h
│   │           │       │   ├── NMCMarkerInfo.h
│   │           │       │   ├── NMCMarkerManager.h
│   │           │       │   ├── NMCNode.h
│   │           │       │   ├── NMCPositioningStrategy.h
│   │           │       │   ├── NMCTagMergeStrategy.h
│   │           │       │   ├── NMCThresholdStrategy.h
│   │           │       │   ├── NMFArrowheadPath.h
│   │           │       │   ├── NMFAuthManager.h
│   │           │       │   ├── NMFCameraCommon.h
│   │           │       │   ├── NMFCameraPosition.h
│   │           │       │   ├── NMFCameraUpdate.h
│   │           │       │   ├── NMFCameraUpdateParams.h
│   │           │       │   ├── NMFCircleOverlay.h
│   │           │       │   ├── NMFCompassView.h
│   │           │       │   ├── NMFFoundation.h
│   │           │       │   ├── NMFGeometry.h
│   │           │       │   ├── NMFGroundOverlay.h
│   │           │       │   ├── NMFIndoorLevel.h
│   │           │       │   ├── NMFIndoorLevelPickerView.h
│   │           │       │   ├── NMFIndoorRegion.h
│   │           │       │   ├── NMFIndoorSelection.h
│   │           │       │   ├── NMFIndoorSelectionDelegate.h
│   │           │       │   ├── NMFIndoorView.h
│   │           │       │   ├── NMFIndoorZone.h
│   │           │       │   ├── NMFInfoWindow.h
│   │           │       │   ├── NMFInfoWindowDefaultTextSource.h
│   │           │       │   ├── NMFLocationButton.h
│   │           │       │   ├── NMFLocationManager.h
│   │           │       │   ├── NMFLocationOverlay.h
│   │           │       │   ├── NMFMapView+IBAdditions.h
│   │           │       │   ├── NMFMapView.h
│   │           │       │   ├── NMFMapViewCameraDelegate.h
│   │           │       │   ├── NMFMapViewDelegate.h
│   │           │       │   ├── NMFMapViewOptionDelegate.h
│   │           │       │   ├── NMFMapViewTouchDelegate.h
│   │           │       │   ├── NMFMarker.h
│   │           │       │   ├── NMFMarkerConstants.h
│   │           │       │   ├── NMFMultipartPath.h
│   │           │       │   ├── NMFMyPositionMode.h
│   │           │       │   ├── NMFNaverMapView.h
│   │           │       │   ├── NMFOfflinePack.h
│   │           │       │   ├── NMFOfflineRegion.h
│   │           │       │   ├── NMFOfflineStorage.h
│   │           │       │   ├── NMFOverlay.h
│   │           │       │   ├── NMFOverlayImage.h
│   │           │       │   ├── NMFPath.h
│   │           │       │   ├── NMFPathColor.h
│   │           │       │   ├── NMFPickable.h
│   │           │       │   ├── NMFPolygonOverlay.h
│   │           │       │   ├── NMFPolylineOverlay.h
│   │           │       │   ├── NMFProjection.h
│   │           │       │   ├── NMFRendererOptions.h
│   │           │       │   ├── NMFScaleView.h
│   │           │       │   ├── NMFSymbol.h
│   │           │       │   ├── NMFTileCoverHelper.h
│   │           │       │   ├── NMFTileId.h
│   │           │       │   ├── NMFTypes.h
│   │           │       │   ├── NMFUtils.h
│   │           │       │   ├── NMFZoomControlView.h
│   │           │       │   ├── NMapsMap.h
│   │           │       │   └── NSBundle+NMFAdditions.h
│   │           │       ├── Info.plist
│   │           │       ├── LICENSE
│   │           │       ├── Modules
│   │           │       │   └── module.modulemap
│   │           │       ├── NMFIndoorLevelPickerCell.nib
│   │           │       │   ├── objects-11.0+.nib
│   │           │       │   └── runtime.nib
│   │           │       ├── NMFIndoorLevelPickerView.nib
│   │           │       │   ├── objects-11.0+.nib
│   │           │       │   └── runtime.nib
│   │           │       ├── NMFInfoWindowDefaultTextSource.nib
│   │           │       ├── NMFNaverMapView.nib
│   │           │       │   ├── objects-11.0+.nib
│   │           │       │   └── runtime.nib
│   │           │       ├── NMFScaleView.nib
│   │           │       ├── NMFZoomControlView.nib
│   │           │       ├── NMapsMap
│   │           │       ├── NOTICE
│   │           │       ├── PrivacyInfo.xcprivacy
│   │           │       ├── default.metallib
│   │           │       ├── en.lproj
│   │           │       │   ├── Foundation.strings
│   │           │       │   └── Localizable.strings
│   │           │       ├── ja.lproj
│   │           │       │   ├── Foundation.strings
│   │           │       │   └── Localizable.strings
│   │           │       ├── ko.lproj
│   │           │       │   ├── Foundation.strings
│   │           │       │   ├── Foundation.stringsdict
│   │           │       │   └── Localizable.strings
│   │           │       └── zh-Hans.lproj
│   │           │           ├── Foundation.strings
│   │           │           └── Localizable.strings
│   │           └── ios-arm64_x86_64-simulator
│   │               └── NMapsMap.framework
│   │                   ├── Assets.car
│   │                   ├── Base.lproj
│   │                   │   └── Foundation.strings
│   │                   ├── Headers
│   │                   │   ├── NMCBuilder.h
│   │                   │   ├── NMCCluster.h
│   │                   │   ├── NMCClusterMarkerInfo.h
│   │                   │   ├── NMCClusterMarkerUpdater.h
│   │                   │   ├── NMCClusterer.h
│   │                   │   ├── NMCClustererUpdateCallback.h
│   │                   │   ├── NMCClusteringKey.h
│   │                   │   ├── NMCComplexBuilder.h
│   │                   │   ├── NMCDefaultClusterMarkerUpdater.h
│   │                   │   ├── NMCDefaultDistanceStrategy.h
│   │                   │   ├── NMCDefaultLeafMarkerUpdater.h
│   │                   │   ├── NMCDefaultMarkerManager.h
│   │                   │   ├── NMCDefaultPositioningStrategy.h
│   │                   │   ├── NMCDefaultTagMergeStrategy.h
│   │                   │   ├── NMCDefaultThresholdStrategy.h
│   │                   │   ├── NMCDistanceStrategy.h
│   │                   │   ├── NMCLeaf.h
│   │                   │   ├── NMCLeafMarkerInfo.h
│   │                   │   ├── NMCLeafMarkerUpdater.h
│   │                   │   ├── NMCMarkerInfo.h
│   │                   │   ├── NMCMarkerManager.h
│   │                   │   ├── NMCNode.h
│   │                   │   ├── NMCPositioningStrategy.h
│   │                   │   ├── NMCTagMergeStrategy.h
│   │                   │   ├── NMCThresholdStrategy.h
│   │                   │   ├── NMFArrowheadPath.h
│   │                   │   ├── NMFAuthManager.h
│   │                   │   ├── NMFCameraCommon.h
│   │                   │   ├── NMFCameraPosition.h
│   │                   │   ├── NMFCameraUpdate.h
│   │                   │   ├── NMFCameraUpdateParams.h
│   │                   │   ├── NMFCircleOverlay.h
│   │                   │   ├── NMFCompassView.h
│   │                   │   ├── NMFFoundation.h
│   │                   │   ├── NMFGeometry.h
│   │                   │   ├── NMFGroundOverlay.h
│   │                   │   ├── NMFIndoorLevel.h
│   │                   │   ├── NMFIndoorLevelPickerView.h
│   │                   │   ├── NMFIndoorRegion.h
│   │                   │   ├── NMFIndoorSelection.h
│   │                   │   ├── NMFIndoorSelectionDelegate.h
│   │                   │   ├── NMFIndoorView.h
│   │                   │   ├── NMFIndoorZone.h
│   │                   │   ├── NMFInfoWindow.h
│   │                   │   ├── NMFInfoWindowDefaultTextSource.h
│   │                   │   ├── NMFLocationButton.h
│   │                   │   ├── NMFLocationManager.h
│   │                   │   ├── NMFLocationOverlay.h
│   │                   │   ├── NMFMapView+IBAdditions.h
│   │                   │   ├── NMFMapView.h
│   │                   │   ├── NMFMapViewCameraDelegate.h
│   │                   │   ├── NMFMapViewDelegate.h
│   │                   │   ├── NMFMapViewOptionDelegate.h
│   │                   │   ├── NMFMapViewTouchDelegate.h
│   │                   │   ├── NMFMarker.h
│   │                   │   ├── NMFMarkerConstants.h
│   │                   │   ├── NMFMultipartPath.h
│   │                   │   ├── NMFMyPositionMode.h
│   │                   │   ├── NMFNaverMapView.h
│   │                   │   ├── NMFOfflinePack.h
│   │                   │   ├── NMFOfflineRegion.h
│   │                   │   ├── NMFOfflineStorage.h
│   │                   │   ├── NMFOverlay.h
│   │                   │   ├── NMFOverlayImage.h
│   │                   │   ├── NMFPath.h
│   │                   │   ├── NMFPathColor.h
│   │                   │   ├── NMFPickable.h
│   │                   │   ├── NMFPolygonOverlay.h
│   │                   │   ├── NMFPolylineOverlay.h
│   │                   │   ├── NMFProjection.h
│   │                   │   ├── NMFRendererOptions.h
│   │                   │   ├── NMFScaleView.h
│   │                   │   ├── NMFSymbol.h
│   │                   │   ├── NMFTileCoverHelper.h
│   │                   │   ├── NMFTileId.h
│   │                   │   ├── NMFTypes.h
│   │                   │   ├── NMFUtils.h
│   │                   │   ├── NMFZoomControlView.h
│   │                   │   ├── NMapsMap.h
│   │                   │   └── NSBundle+NMFAdditions.h
│   │                   ├── Info.plist
│   │                   ├── LICENSE
│   │                   ├── Modules
│   │                   │   └── module.modulemap
│   │                   ├── NMFIndoorLevelPickerCell.nib
│   │                   │   ├── objects-11.0+.nib
│   │                   │   └── runtime.nib
│   │                   ├── NMFIndoorLevelPickerView.nib
│   │                   │   ├── objects-11.0+.nib
│   │                   │   └── runtime.nib
│   │                   ├── NMFInfoWindowDefaultTextSource.nib
│   │                   ├── NMFNaverMapView.nib
│   │                   │   ├── objects-11.0+.nib
│   │                   │   └── runtime.nib
│   │                   ├── NMFScaleView.nib
│   │                   ├── NMFZoomControlView.nib
│   │                   ├── NMapsMap
│   │                   ├── NOTICE
│   │                   ├── PrivacyInfo.xcprivacy
│   │                   ├── _CodeSignature
│   │                   │   └── CodeResources
│   │                   ├── default.metallib
│   │                   ├── en.lproj
│   │                   │   ├── Foundation.strings
│   │                   │   └── Localizable.strings
│   │                   ├── ja.lproj
│   │                   │   ├── Foundation.strings
│   │                   │   └── Localizable.strings
│   │                   ├── ko.lproj
│   │                   │   ├── Foundation.strings
│   │                   │   ├── Foundation.stringsdict
│   │                   │   └── Localizable.strings
│   │                   └── zh-Hans.lproj
│   │                       ├── Foundation.strings
│   │                       └── Localizable.strings
│   ├── Pods.xcodeproj
│   │   ├── project.pbxproj
│   │   └── xcuserdata
│   │       └── simgwanhyeok.xcuserdatad
│   │           └── xcschemes
│   │               ├── NMapsGeometry.xcscheme
│   │               ├── NMapsMap.xcscheme
│   │               ├── Pods-Dokodachi-DokodachiUITests.xcscheme
│   │               ├── Pods-Dokodachi.xcscheme
│   │               ├── Pods-DokodachiTests.xcscheme
│   │               ├── RxCocoa.xcscheme
│   │               ├── RxRelay.xcscheme
│   │               ├── RxSwift.xcscheme
│   │               ├── Socket.IO-Client-Swift.xcscheme
│   │               ├── Starscream-Starscream_Privacy.xcscheme
│   │               ├── Starscream.xcscheme
│   │               └── xcschememanagement.plist
│   ├── RxCocoa
│   │   ├── LICENSE.md
│   │   ├── Platform
│   │   │   ├── DataStructures
│   │   │   │   ├── Bag.swift
│   │   │   │   ├── InfiniteSequence.swift
│   │   │   │   ├── PriorityQueue.swift
│   │   │   │   └── Queue.swift
│   │   │   ├── DispatchQueue+Extensions.swift
│   │   │   ├── Platform.Darwin.swift
│   │   │   ├── Platform.Linux.swift
│   │   │   └── RecursiveLock.swift
│   │   ├── README.md
│   │   └── RxCocoa
│   │       ├── Common
│   │       │   ├── ControlTarget.swift
│   │       │   ├── DelegateProxy.swift
│   │       │   ├── DelegateProxyType.swift
│   │       │   ├── Infallible+Bind.swift
│   │       │   ├── Observable+Bind.swift
│   │       │   ├── RxCocoaObjCRuntimeError+Extensions.swift
│   │       │   ├── RxTarget.swift
│   │       │   ├── SectionedViewDataSourceType.swift
│   │       │   └── TextInput.swift
│   │       ├── Foundation
│   │       │   ├── KVORepresentable+CoreGraphics.swift
│   │       │   ├── KVORepresentable+Swift.swift
│   │       │   ├── KVORepresentable.swift
│   │       │   ├── NSObject+Rx+KVORepresentable.swift
│   │       │   ├── NSObject+Rx+RawRepresentable.swift
│   │       │   ├── NSObject+Rx.swift
│   │       │   ├── NotificationCenter+Rx.swift
│   │       │   └── URLSession+Rx.swift
│   │       ├── Runtime
│   │       │   ├── _RX.m
│   │       │   ├── _RXDelegateProxy.m
│   │       │   ├── _RXKVOObserver.m
│   │       │   ├── _RXObjCRuntime.m
│   │       │   └── include
│   │       │       ├── RxCocoaRuntime.h
│   │       │       ├── _RX.h
│   │       │       ├── _RXDelegateProxy.h
│   │       │       ├── _RXKVOObserver.h
│   │       │       └── _RXObjCRuntime.h
│   │       ├── RxCocoa.h
│   │       ├── RxCocoa.swift
│   │       ├── Traits
│   │       │   ├── ControlEvent.swift
│   │       │   ├── ControlProperty.swift
│   │       │   ├── Driver
│   │       │   │   ├── BehaviorRelay+Driver.swift
│   │       │   │   ├── ControlEvent+Driver.swift
│   │       │   │   ├── ControlProperty+Driver.swift
│   │       │   │   ├── Driver+Subscription.swift
│   │       │   │   ├── Driver.swift
│   │       │   │   ├── Infallible+Driver.swift
│   │       │   │   └── ObservableConvertibleType+Driver.swift
│   │       │   ├── SharedSequence
│   │       │   │   ├── ObservableConvertibleType+SharedSequence.swift
│   │       │   │   ├── SchedulerType+SharedSequence.swift
│   │       │   │   ├── SharedSequence+Concurrency.swift
│   │       │   │   ├── SharedSequence+Operators+arity.swift
│   │       │   │   ├── SharedSequence+Operators.swift
│   │       │   │   └── SharedSequence.swift
│   │       │   └── Signal
│   │       │       ├── ControlEvent+Signal.swift
│   │       │       ├── ObservableConvertibleType+Signal.swift
│   │       │       ├── PublishRelay+Signal.swift
│   │       │       ├── Signal+Subscription.swift
│   │       │       └── Signal.swift
│   │       ├── iOS
│   │       │   ├── DataSources
│   │       │   │   ├── RxCollectionViewReactiveArrayDataSource.swift
│   │       │   │   ├── RxPickerViewAdapter.swift
│   │       │   │   └── RxTableViewReactiveArrayDataSource.swift
│   │       │   ├── Events
│   │       │   │   └── ItemEvents.swift
│   │       │   ├── NSTextStorage+Rx.swift
│   │       │   ├── Protocols
│   │       │   │   ├── RxCollectionViewDataSourceType.swift
│   │       │   │   ├── RxPickerViewDataSourceType.swift
│   │       │   │   └── RxTableViewDataSourceType.swift
│   │       │   ├── Proxies
│   │       │   │   ├── RxCollectionViewDataSourcePrefetchingProxy.swift
│   │       │   │   ├── RxCollectionViewDataSourceProxy.swift
│   │       │   │   ├── RxCollectionViewDelegateProxy.swift
│   │       │   │   ├── RxNavigationControllerDelegateProxy.swift
│   │       │   │   ├── RxPickerViewDataSourceProxy.swift
│   │       │   │   ├── RxPickerViewDelegateProxy.swift
│   │       │   │   ├── RxScrollViewDelegateProxy.swift
│   │       │   │   ├── RxSearchBarDelegateProxy.swift
│   │       │   │   ├── RxSearchControllerDelegateProxy.swift
│   │       │   │   ├── RxTabBarControllerDelegateProxy.swift
│   │       │   │   ├── RxTabBarDelegateProxy.swift
│   │       │   │   ├── RxTableViewDataSourcePrefetchingProxy.swift
│   │       │   │   ├── RxTableViewDataSourceProxy.swift
│   │       │   │   ├── RxTableViewDelegateProxy.swift
│   │       │   │   ├── RxTextStorageDelegateProxy.swift
│   │       │   │   ├── RxTextViewDelegateProxy.swift
│   │       │   │   └── RxWKNavigationDelegateProxy.swift
│   │       │   ├── UIActivityIndicatorView+Rx.swift
│   │       │   ├── UIApplication+Rx.swift
│   │       │   ├── UIBarButtonItem+Rx.swift
│   │       │   ├── UIButton+Rx.swift
│   │       │   ├── UICollectionView+Rx.swift
│   │       │   ├── UIControl+Rx.swift
│   │       │   ├── UIDatePicker+Rx.swift
│   │       │   ├── UIGestureRecognizer+Rx.swift
│   │       │   ├── UINavigationController+Rx.swift
│   │       │   ├── UIPickerView+Rx.swift
│   │       │   ├── UIRefreshControl+Rx.swift
│   │       │   ├── UIScrollView+Rx.swift
│   │       │   ├── UISearchBar+Rx.swift
│   │       │   ├── UISearchController+Rx.swift
│   │       │   ├── UISegmentedControl+Rx.swift
│   │       │   ├── UISlider+Rx.swift
│   │       │   ├── UIStepper+Rx.swift
│   │       │   ├── UISwitch+Rx.swift
│   │       │   ├── UITabBar+Rx.swift
│   │       │   ├── UITabBarController+Rx.swift
│   │       │   ├── UITableView+Rx.swift
│   │       │   ├── UITextField+Rx.swift
│   │       │   ├── UITextView+Rx.swift
│   │       │   └── WKWebView+Rx.swift
│   │       └── macOS
│   │           ├── NSButton+Rx.swift
│   │           ├── NSControl+Rx.swift
│   │           ├── NSSlider+Rx.swift
│   │           ├── NSTextField+Rx.swift
│   │           ├── NSTextView+Rx.swift
│   │           └── NSView+Rx.swift
│   ├── RxRelay
│   │   ├── LICENSE.md
│   │   ├── README.md
│   │   └── RxRelay
│   │       ├── BehaviorRelay.swift
│   │       ├── Observable+Bind.swift
│   │       ├── PublishRelay.swift
│   │       ├── ReplayRelay.swift
│   │       └── Utils.swift
│   ├── RxSwift
│   │   ├── LICENSE.md
│   │   ├── Platform
│   │   │   ├── AtomicInt.swift
│   │   │   ├── DataStructures
│   │   │   │   ├── Bag.swift
│   │   │   │   ├── InfiniteSequence.swift
│   │   │   │   ├── PriorityQueue.swift
│   │   │   │   └── Queue.swift
│   │   │   ├── DispatchQueue+Extensions.swift
│   │   │   ├── Platform.Darwin.swift
│   │   │   ├── Platform.Linux.swift
│   │   │   └── RecursiveLock.swift
│   │   ├── README.md
│   │   └── RxSwift
│   │       ├── AnyObserver.swift
│   │       ├── Binder.swift
│   │       ├── Cancelable.swift
│   │       ├── Concurrency
│   │       │   ├── AsyncLock.swift
│   │       │   ├── Lock.swift
│   │       │   ├── LockOwnerType.swift
│   │       │   ├── SynchronizedDisposeType.swift
│   │       │   ├── SynchronizedOnType.swift
│   │       │   └── SynchronizedUnsubscribeType.swift
│   │       ├── ConnectableObservableType.swift
│   │       ├── Date+Dispatch.swift
│   │       ├── Disposable.swift
│   │       ├── Disposables
│   │       │   ├── AnonymousDisposable.swift
│   │       │   ├── BinaryDisposable.swift
│   │       │   ├── BooleanDisposable.swift
│   │       │   ├── CompositeDisposable.swift
│   │       │   ├── Disposables.swift
│   │       │   ├── DisposeBag.swift
│   │       │   ├── DisposeBase.swift
│   │       │   ├── NopDisposable.swift
│   │       │   ├── RefCountDisposable.swift
│   │       │   ├── ScheduledDisposable.swift
│   │       │   ├── SerialDisposable.swift
│   │       │   ├── SingleAssignmentDisposable.swift
│   │       │   └── SubscriptionDisposable.swift
│   │       ├── Errors.swift
│   │       ├── Event.swift
│   │       ├── Extensions
│   │       │   └── Bag+Rx.swift
│   │       ├── GroupedObservable.swift
│   │       ├── ImmediateSchedulerType.swift
│   │       ├── Observable+Concurrency.swift
│   │       ├── Observable.swift
│   │       ├── ObservableConvertibleType.swift
│   │       ├── ObservableType+Extensions.swift
│   │       ├── ObservableType.swift
│   │       ├── Observables
│   │       │   ├── AddRef.swift
│   │       │   ├── Amb.swift
│   │       │   ├── AsMaybe.swift
│   │       │   ├── AsSingle.swift
│   │       │   ├── Buffer.swift
│   │       │   ├── Catch.swift
│   │       │   ├── CombineLatest+Collection.swift
│   │       │   ├── CombineLatest+arity.swift
│   │       │   ├── CombineLatest.swift
│   │       │   ├── CompactMap.swift
│   │       │   ├── Concat.swift
│   │       │   ├── Create.swift
│   │       │   ├── Debounce.swift
│   │       │   ├── Debug.swift
│   │       │   ├── Decode.swift
│   │       │   ├── DefaultIfEmpty.swift
│   │       │   ├── Deferred.swift
│   │       │   ├── Delay.swift
│   │       │   ├── DelaySubscription.swift
│   │       │   ├── Dematerialize.swift
│   │       │   ├── DistinctUntilChanged.swift
│   │       │   ├── Do.swift
│   │       │   ├── ElementAt.swift
│   │       │   ├── Empty.swift
│   │       │   ├── Enumerated.swift
│   │       │   ├── Error.swift
│   │       │   ├── Filter.swift
│   │       │   ├── First.swift
│   │       │   ├── Generate.swift
│   │       │   ├── GroupBy.swift
│   │       │   ├── Just.swift
│   │       │   ├── Map.swift
│   │       │   ├── Materialize.swift
│   │       │   ├── Merge.swift
│   │       │   ├── Multicast.swift
│   │       │   ├── Never.swift
│   │       │   ├── ObserveOn.swift
│   │       │   ├── Optional.swift
│   │       │   ├── Producer.swift
│   │       │   ├── Range.swift
│   │       │   ├── Reduce.swift
│   │       │   ├── Repeat.swift
│   │       │   ├── RetryWhen.swift
│   │       │   ├── Sample.swift
│   │       │   ├── Scan.swift
│   │       │   ├── Sequence.swift
│   │       │   ├── ShareReplayScope.swift
│   │       │   ├── SingleAsync.swift
│   │       │   ├── Sink.swift
│   │       │   ├── Skip.swift
│   │       │   ├── SkipUntil.swift
│   │       │   ├── SkipWhile.swift
│   │       │   ├── StartWith.swift
│   │       │   ├── SubscribeOn.swift
│   │       │   ├── Switch.swift
│   │       │   ├── SwitchIfEmpty.swift
│   │       │   ├── Take.swift
│   │       │   ├── TakeLast.swift
│   │       │   ├── TakeWithPredicate.swift
│   │       │   ├── Throttle.swift
│   │       │   ├── Timeout.swift
│   │       │   ├── Timer.swift
│   │       │   ├── ToArray.swift
│   │       │   ├── Using.swift
│   │       │   ├── Window.swift
│   │       │   ├── WithLatestFrom.swift
│   │       │   ├── WithUnretained.swift
│   │       │   ├── Zip+Collection.swift
│   │       │   ├── Zip+arity.swift
│   │       │   └── Zip.swift
│   │       ├── ObserverType.swift
│   │       ├── Observers
│   │       │   ├── AnonymousObserver.swift
│   │       │   ├── ObserverBase.swift
│   │       │   └── TailRecursiveSink.swift
│   │       ├── Reactive.swift
│   │       ├── Rx.swift
│   │       ├── RxMutableBox.swift
│   │       ├── SchedulerType.swift
│   │       ├── Schedulers
│   │       │   ├── ConcurrentDispatchQueueScheduler.swift
│   │       │   ├── ConcurrentMainScheduler.swift
│   │       │   ├── CurrentThreadScheduler.swift
│   │       │   ├── HistoricalScheduler.swift
│   │       │   ├── HistoricalSchedulerTimeConverter.swift
│   │       │   ├── Internal
│   │       │   │   ├── DispatchQueueConfiguration.swift
│   │       │   │   ├── InvocableScheduledItem.swift
│   │       │   │   ├── InvocableType.swift
│   │       │   │   ├── ScheduledItem.swift
│   │       │   │   └── ScheduledItemType.swift
│   │       │   ├── MainScheduler.swift
│   │       │   ├── OperationQueueScheduler.swift
│   │       │   ├── RecursiveScheduler.swift
│   │       │   ├── SchedulerServices+Emulation.swift
│   │       │   ├── SerialDispatchQueueScheduler.swift
│   │       │   ├── VirtualTimeConverterType.swift
│   │       │   └── VirtualTimeScheduler.swift
│   │       ├── Subjects
│   │       │   ├── AsyncSubject.swift
│   │       │   ├── BehaviorSubject.swift
│   │       │   ├── PublishSubject.swift
│   │       │   ├── ReplaySubject.swift
│   │       │   └── SubjectType.swift
│   │       ├── SwiftSupport
│   │       │   └── SwiftSupport.swift
│   │       └── Traits
│   │           ├── Infallible
│   │           │   ├── Infallible+CombineLatest+Collection.swift
│   │           │   ├── Infallible+CombineLatest+arity.swift
│   │           │   ├── Infallible+Concurrency.swift
│   │           │   ├── Infallible+Create.swift
│   │           │   ├── Infallible+Debug.swift
│   │           │   ├── Infallible+Operators.swift
│   │           │   ├── Infallible+Zip+arity.swift
│   │           │   ├── Infallible.swift
│   │           │   └── ObservableConvertibleType+Infallible.swift
│   │           └── PrimitiveSequence
│   │               ├── Completable+AndThen.swift
│   │               ├── Completable.swift
│   │               ├── Maybe.swift
│   │               ├── ObservableType+PrimitiveSequence.swift
│   │               ├── PrimitiveSequence+Concurrency.swift
│   │               ├── PrimitiveSequence+Zip+arity.swift
│   │               ├── PrimitiveSequence.swift
│   │               └── Single.swift
│   ├── Socket.IO-Client-Swift
│   │   ├── LICENSE
│   │   ├── README.md
│   │   └── Source
│   │       └── SocketIO
│   │           ├── Ack
│   │           │   ├── SocketAckEmitter.swift
│   │           │   └── SocketAckManager.swift
│   │           ├── Client
│   │           │   ├── SocketAnyEvent.swift
│   │           │   ├── SocketEventHandler.swift
│   │           │   ├── SocketIOClient.swift
│   │           │   ├── SocketIOClientConfiguration.swift
│   │           │   ├── SocketIOClientOption.swift
│   │           │   ├── SocketIOClientSpec.swift
│   │           │   ├── SocketIOStatus.swift
│   │           │   └── SocketRawView.swift
│   │           ├── Engine
│   │           │   ├── SocketEngine.swift
│   │           │   ├── SocketEngineClient.swift
│   │           │   ├── SocketEnginePacketType.swift
│   │           │   ├── SocketEnginePollable.swift
│   │           │   ├── SocketEngineSpec.swift
│   │           │   └── SocketEngineWebsocket.swift
│   │           ├── Manager
│   │           │   ├── SocketManager.swift
│   │           │   └── SocketManagerSpec.swift
│   │           ├── Parse
│   │           │   ├── SocketPacket.swift
│   │           │   └── SocketParsable.swift
│   │           └── Util
│   │               ├── SocketExtensions.swift
│   │               ├── SocketLogger.swift
│   │               ├── SocketStringReader.swift
│   │               └── SocketTypes.swift
│   ├── Starscream
│   │   ├── LICENSE
│   │   ├── README.md
│   │   └── Sources
│   │       ├── Compression
│   │       │   ├── Compression.swift
│   │       │   └── WSCompression.swift
│   │       ├── DataBytes
│   │       │   └── Data+Extensions.swift
│   │       ├── Engine
│   │       │   ├── Engine.swift
│   │       │   ├── NativeEngine.swift
│   │       │   └── WSEngine.swift
│   │       ├── Framer
│   │       │   ├── FoundationHTTPHandler.swift
│   │       │   ├── FoundationHTTPServerHandler.swift
│   │       │   ├── FrameCollector.swift
│   │       │   ├── Framer.swift
│   │       │   ├── HTTPHandler.swift
│   │       │   └── StringHTTPHandler.swift
│   │       ├── PrivacyInfo.xcprivacy
│   │       ├── Security
│   │       │   ├── FoundationSecurity.swift
│   │       │   └── Security.swift
│   │       ├── Server
│   │       │   ├── Server.swift
│   │       │   └── WebSocketServer.swift
│   │       ├── Starscream
│   │       │   └── WebSocket.swift
│   │       └── Transport
│   │           ├── FoundationTransport.swift
│   │           ├── TCPTransport.swift
│   │           └── Transport.swift
│   └── Target Support Files
│       ├── NMapsGeometry
│       │   ├── NMapsGeometry-xcframeworks-input-files.xcfilelist
│       │   ├── NMapsGeometry-xcframeworks-output-files.xcfilelist
│       │   ├── NMapsGeometry-xcframeworks.sh
│       │   ├── NMapsGeometry.debug.xcconfig
│       │   └── NMapsGeometry.release.xcconfig
│       ├── NMapsMap
│       │   ├── NMapsMap-xcframeworks-input-files.xcfilelist
│       │   ├── NMapsMap-xcframeworks-output-files.xcfilelist
│       │   ├── NMapsMap-xcframeworks.sh
│       │   ├── NMapsMap.debug.xcconfig
│       │   └── NMapsMap.release.xcconfig
│       ├── Pods-Dokodachi
│       │   ├── Pods-Dokodachi-Info.plist
│       │   ├── Pods-Dokodachi-acknowledgements.markdown
│       │   ├── Pods-Dokodachi-acknowledgements.plist
│       │   ├── Pods-Dokodachi-dummy.m
│       │   ├── Pods-Dokodachi-frameworks-Debug-input-files.xcfilelist
│       │   ├── Pods-Dokodachi-frameworks-Debug-output-files.xcfilelist
│       │   ├── Pods-Dokodachi-frameworks-Release-input-files.xcfilelist
│       │   ├── Pods-Dokodachi-frameworks-Release-output-files.xcfilelist
│       │   ├── Pods-Dokodachi-frameworks.sh
│       │   ├── Pods-Dokodachi-umbrella.h
│       │   ├── Pods-Dokodachi.debug.xcconfig
│       │   ├── Pods-Dokodachi.modulemap
│       │   └── Pods-Dokodachi.release.xcconfig
│       ├── Pods-Dokodachi-DokodachiUITests
│       │   ├── Pods-Dokodachi-DokodachiUITests-Info.plist
│       │   ├── Pods-Dokodachi-DokodachiUITests-acknowledgements.markdown
│       │   ├── Pods-Dokodachi-DokodachiUITests-acknowledgements.plist
│       │   ├── Pods-Dokodachi-DokodachiUITests-dummy.m
│       │   ├── Pods-Dokodachi-DokodachiUITests-frameworks-Debug-input-files.xcfilelist
│       │   ├── Pods-Dokodachi-DokodachiUITests-frameworks-Debug-output-files.xcfilelist
│       │   ├── Pods-Dokodachi-DokodachiUITests-frameworks-Release-input-files.xcfilelist
│       │   ├── Pods-Dokodachi-DokodachiUITests-frameworks-Release-output-files.xcfilelist
│       │   ├── Pods-Dokodachi-DokodachiUITests-frameworks.sh
│       │   ├── Pods-Dokodachi-DokodachiUITests-umbrella.h
│       │   ├── Pods-Dokodachi-DokodachiUITests.debug.xcconfig
│       │   ├── Pods-Dokodachi-DokodachiUITests.modulemap
│       │   └── Pods-Dokodachi-DokodachiUITests.release.xcconfig
│       ├── Pods-DokodachiTests
│       │   ├── Pods-DokodachiTests-Info.plist
│       │   ├── Pods-DokodachiTests-acknowledgements.markdown
│       │   ├── Pods-DokodachiTests-acknowledgements.plist
│       │   ├── Pods-DokodachiTests-dummy.m
│       │   ├── Pods-DokodachiTests-umbrella.h
│       │   ├── Pods-DokodachiTests.debug.xcconfig
│       │   ├── Pods-DokodachiTests.modulemap
│       │   └── Pods-DokodachiTests.release.xcconfig
│       ├── RxCocoa
│       │   ├── RxCocoa-Info.plist
│       │   ├── RxCocoa-dummy.m
│       │   ├── RxCocoa-prefix.pch
│       │   ├── RxCocoa-umbrella.h
│       │   ├── RxCocoa.debug.xcconfig
│       │   ├── RxCocoa.modulemap
│       │   └── RxCocoa.release.xcconfig
│       ├── RxRelay
│       │   ├── RxRelay-Info.plist
│       │   ├── RxRelay-dummy.m
│       │   ├── RxRelay-prefix.pch
│       │   ├── RxRelay-umbrella.h
│       │   ├── RxRelay.debug.xcconfig
│       │   ├── RxRelay.modulemap
│       │   └── RxRelay.release.xcconfig
│       ├── RxSwift
│       │   ├── RxSwift-Info.plist
│       │   ├── RxSwift-dummy.m
│       │   ├── RxSwift-prefix.pch
│       │   ├── RxSwift-umbrella.h
│       │   ├── RxSwift.debug.xcconfig
│       │   ├── RxSwift.modulemap
│       │   └── RxSwift.release.xcconfig
│       ├── Socket.IO-Client-Swift
│       │   ├── Socket.IO-Client-Swift-Info.plist
│       │   ├── Socket.IO-Client-Swift-dummy.m
│       │   ├── Socket.IO-Client-Swift-prefix.pch
│       │   ├── Socket.IO-Client-Swift-umbrella.h
│       │   ├── Socket.IO-Client-Swift.debug.xcconfig
│       │   ├── Socket.IO-Client-Swift.modulemap
│       │   └── Socket.IO-Client-Swift.release.xcconfig
│       └── Starscream
│           ├── ResourceBundle-Starscream_Privacy-Starscream-Info.plist
│           ├── Starscream-Info.plist
│           ├── Starscream-dummy.m
│           ├── Starscream-prefix.pch
│           ├── Starscream-umbrella.h
│           ├── Starscream.debug.xcconfig
│           ├── Starscream.modulemap
│           └── Starscream.release.xcconfig
└── README.md

145 directories, 726 files
```
