import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var userLocation: CLLocation?
    @Published var customPin = [PinData]()
    @Published var checkInAlert = false
    @Published var checkInMessage = ""
    
    let locationManager = CLLocationManager()
    static let shared = LocationManager()
    
    override init() {
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.distanceFilter = 0.5
        loadJson()
    }
    
    func requestPermission() {
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.userLocation = location
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
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
            let overlay = MKCircle(center: customPin[checkInNumber].coordinate, radius: 3)
            let renderer = MKCircleRenderer(circle: overlay)
            // 現在地の座標を(MKMapPoint)に変換
            let mapPoint = MKMapPoint(userLocation.coordinate)
            // マップ上のポイントを MKCircleRenderer 領域内のポイントに変換
            let rendererPoint = renderer.point(for: mapPoint)
            checkInAlert = true
            if renderer.path.contains(rendererPoint) {
                checkInMessage = "\(checkInNumber)チェックインが完了しました!"
                print("----------------------\(checkInNumber)チェックインが完了しました。----------------------")
            } else {
                checkInMessage = "\(checkInNumber)チェックインが未完了です。領域内に入ってください!"
                print("----------------------\(checkInNumber)チェックインが未完了です。領域内に入ってください。----------------------")
            }
        }
        print("locations.last\(String(describing: userLocation?.coordinate))")
        print("香椎線のチェックインを行いました！")
    }
}
