import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var notificationModel = NotificationModel()
    @Published var userLocation: CLLocation?
    @Published var customPin = [PinData]()
    @Published var information = [InformationData]()
    @Published var checkInNumber = 0
    @Published var checkInAlert = false
    @Published var isAnimation = false
    @Published var isDenied = false
    @Published var geoDistance = 100
    @Published var address = ""
    @Published var notificationCount = 1
    @Published var notificationTime = 2
    @Published var trackingModes: String?
    @Published var isSpeechGuide = false
    @Published var moniteringRegions: [CLRegion]?
    
    static let shared = LocationManager()
    let locationManager = CLLocationManager()
    var moniteringRegion = CLCircularRegion()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.showsBackgroundLocationIndicator = true
        // 現在地の座標をすぐに呼び出す
        locationManager.startUpdatingLocation()
        loadMapLocationJson()
        loadInformationJson()
        loadUserDefauls()
        locationAccuracy()
        moniteringCounter()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location
    }
    
    // モニタリング開始成功時
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {

    }

    // モニタリングに失敗時
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        
    }

    // ジオフェンス領域侵入時
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        var count = 0
        let _ = Timer.scheduledTimer(withTimeInterval: Double(notificationTime), repeats: true) { timer in
            count += 1
            
            if count >= self.notificationCount {
//                self.notificationModel.removeNotification()
                timer.invalidate() // タイマー停止
            }
            if !self.notificationModel.removeNotificationRequests {
                print("Timer fired! Count: \(count)")
                self.notificationModel.setNotification(notify: self.isSpeechGuide)
            } else {
                timer.invalidate()
                print("TimerStop")
            }
        }
    }

    // ジオフェンスの情報が取得できない時
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {

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
    
    func loadMapLocationJson() {
        guard let path = Bundle.main.path(forResource: "MapLocationData", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            let locationData = try Data(contentsOf: url)
            customPin = try JSONDecoder().decode([PinData].self, from: locationData)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func loadInformationJson() {
        guard let path = Bundle.main.path(forResource: "InformationData", ofType: "json") else { return }
        let url = URL(fileURLWithPath: path)

        do {
            let informationData = try Data(contentsOf: url)
            information = try JSONDecoder().decode([InformationData].self, from: informationData)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func checkLocation(checkInNumber: Int) {
        locationManager.startUpdatingLocation()
        if let userLocation = userLocation {
            let overlay = MKCircle(center: customPin[checkInNumber].coordinate, radius: 100)
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
        locationManager.allowsBackgroundLocationUpdates = true
        // CheckInViewで選択したピンのモニタリングを開始
        moniteringRegion = CLCircularRegion(center: customPin[checkInNumber].coordinate, radius: CLLocationDistance(geoDistance), identifier: "\(customPin[checkInNumber].title)")
        // モニタリングは最大20個、半径は１〜400mまで
        locationManager.startMonitoring(for: moniteringRegion)
        print("maximumRegionMonitoringDistance: \(locationManager.maximumRegionMonitoringDistance)")
    }
    // モニタリング停止
    func moniteringStop(moniteringNumber: Int) {
        checkInNumber = moniteringNumber
        locationManager.allowsBackgroundLocationUpdates = false
        moniteringRegion = CLCircularRegion(center: customPin[checkInNumber].coordinate, radius: CLLocationDistance(geoDistance), identifier: "\(customPin[checkInNumber].title)")
        locationManager.stopMonitoring(for: moniteringRegion)
    }
    // モニタリング全停止
    func removeMonitoring() {
        locationManager.monitoredRegions.forEach {
            locationManager.stopMonitoring(for: $0)
        }
        moniteringRegions = nil
    }
    // モニタリング数確認
    func moniteringCounter() {
        let count = locationManager.monitoredRegions.count
        moniteringRegions = Array(locationManager.monitoredRegions)
        print("モニタリング数確認: \(count)")
    }
    // 現在の状態(領域内or領域外)を取得
    func requestState(moniteringNumber: Int) {
        locationManager.requestState(for: moniteringRegion)
    }
    
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
    // 位置情報の更新頻度
    func locationAccuracy() {
        guard trackingModes != nil else { return }
        switch trackingModes {
        case "位置情報追跡":
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.distanceFilter = 2.0
        case "バッテリー節約":
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            locationManager.distanceFilter = 100.0
        default:
            break
        }
    }
    // UserDefaultsの値の読み込み
    func loadUserDefauls() {
        let geoDistance = UserDefaults.standard.integer(forKey: "geoDistance")
        let notificationCount = UserDefaults.standard.integer(forKey: "notificationCount")
        let notificationTime = UserDefaults.standard.integer(forKey: "notificationTime")
        let trackingModes = UserDefaults.standard.string(forKey: "trackingModes") ?? "位置情報追跡"
        let isSpeechGuide = UserDefaults.standard.bool(forKey: "isSpeechGuide")
        self.geoDistance = geoDistance
        self.notificationCount = notificationCount
        self.notificationTime = notificationTime
        self.trackingModes = trackingModes
        self.isSpeechGuide = isSpeechGuide
    }
}
