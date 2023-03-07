import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var notificationModel = NotificationModel()
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?
    @Published var customPin = [PinData]()
    @Published var checkInNumber = 0
    @Published var checkInAlert = false
    @Published var isAnimation = false
    @Published var isDenied = false
    @Published var geoDistance = 100
    @Published var address = ""
    
    let locationManager = CLLocationManager()
    var moniteringRegion = CLCircularRegion()
    static let shared = LocationManager()
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 2.0
        self.locationManager.showsBackgroundLocationIndicator = true
        // 現在地の座標をすぐに呼び出す
        self.locationManager.startUpdatingLocation()
        loadJson()
    }
    
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    // モニタリング開始成功時
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("モニタリング開始")
    }

    // モニタリングに失敗時
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("モニタリング失敗")
    }

    // ジオフェンス領域侵入時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("ジオフェンス侵入")
        var count = 0
        let timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { timer in
            count += 1
            self.notificationModel.setNotification()
            print("Timer fired! Count: \(count)")
            
            if count >= 4 {
                self.notificationModel.removeNotification()
                timer.invalidate() // タイマーを停止する
            }
        }
    }

    // ジオフェンス領域離脱時
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("ジオフェンス離脱")
    }

    // ジオフェンスの情報が取得できない時
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("モニタリングエラー")
    }

    // requestStateが呼ばれた時
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        if state == .inside {
            print("領域内")
        } else {
            print("領域外")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        // ユーザーが位置情報を選択してない場合
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        // ペアレンタルコントロールなどの制限がかかっている場合
        case .restricted:
            manager.requestLocation()
        // ユーザーが設定から位置情報を許可してない場合
        case .denied:
            self.isDenied = true
            manager.requestWhenInUseAuthorization()
        // ユーザーが位置情報を許可している場合
        case .authorizedAlways, .authorizedWhenInUse:
            manager.requestLocation()
        default:
            break
        }
    }
    
    func loadJson() {
        guard let path = Bundle.main.path(forResource: "MapLocationData", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            let locationData = try Data(contentsOf: url)
            self.customPin = try JSONDecoder().decode([PinData].self, from: locationData)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkLocation(checkInNumber: Int) {
        self.locationManager.startUpdatingLocation()
        if let userLocation = userLocation {
            let overlay = MKCircle(center: customPin[checkInNumber].coordinate, radius: 20)
            let renderer = MKCircleRenderer(circle: overlay)
            // 現在地の座標を(MKMapPoint)に変換
            let mapPoint = MKMapPoint(userLocation.coordinate)
            // マップ上のポイントを MKCircleRenderer 領域内のポイントに変換
            let rendererPoint = renderer.point(for: mapPoint)
            if renderer.path.contains(rendererPoint) {
                isAnimation = true
            } else {
                checkInAlert = true
            }
        }
    }
    // モニタリング開始
    func moniteringStart(moniteringNumber: Int) {
        checkInNumber = moniteringNumber
        self.locationManager.allowsBackgroundLocationUpdates = true
        // CheckInViewで選択したピンのモニタリングを開始
        self.moniteringRegion = CLCircularRegion.init(center: customPin[checkInNumber].coordinate, radius: CLLocationDistance(geoDistance), identifier: "monitoringRegion")
        self.locationManager.startMonitoring(for: self.moniteringRegion)
    }
    // モニタリング停止
    func moniteringStop(moniteringNumber: Int) {
        self.locationManager.allowsBackgroundLocationUpdates = false
        self.locationManager.stopMonitoring(for: self.moniteringRegion)
    }
    // 現在の状態(領域内or領域外)を取得
    func requestState(moniteringNumber: Int) {
        self.locationManager.requestState(for: self.moniteringRegion)
    }
    // 通知を知らせる範囲(ジオフェンス)
    func changeGeoDistance(geoDistance: Int) {
        self.geoDistance = geoDistance
    }
    // 逆ジオコーディング
    func reverseGeocoding(checkInNumber: Int) {
        let location = CLLocation(latitude: customPin[checkInNumber].latitude, longitude: customPin[checkInNumber].longitude)
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
            if let firstPlacemark = placemarks?.first {
                var placeName = ""
                // 都道府県
                if let prefectures = firstPlacemark.administrativeArea {
                    placeName.append(prefectures)
                }
                // 市区町村
                if let municipalities = firstPlacemark.locality {
                    placeName.append(municipalities)
                }
                // 番地
                if let address = firstPlacemark.thoroughfare {
                    placeName.append(address)
                } else if let address = firstPlacemark.subLocality {
                    placeName.append(address)
                }
                self.address = placeName
            }
        }
    }
}
