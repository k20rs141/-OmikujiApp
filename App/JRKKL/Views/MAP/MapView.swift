import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager: LocationManager
    @Binding var checkInView: Bool
    @Binding var checkInNumber: Int
    @Binding var tappedLocation: CLLocationCoordinate2D?
    @Binding var showUserLocation: Bool
    @Binding var mapConfiguration: String
    
    public typealias UIViewType = MKMapView
    var mapView = MKMapView()
    var mapType = MKStandardMapConfiguration(elevationStyle: .realistic)
    
    public func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "KashiiLineAnnotation")
        mapView.selectableMapFeatures = [.pointsOfInterest]
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .followWithHeading
        
        mapType.showsTraffic = true
        mapView.preferredConfiguration = mapType
        
        // コンパスの表示
        let compass = MKCompassButton(mapView: mapView)
        compass.compassVisibility = .adaptive
        compass.frame = CGRect(x: UIScreen.main.bounds.width * 0.85, y: UIScreen.main.bounds.height * 0.2, width: 40, height: 40)
        mapView.addSubview(compass)
        // デフォルトのコンパスを非表示
        mapView.showsCompass = false
        
        mapView.removeAnnotations(mapView.annotations)
        
        for i in 0 ..< locationManager.customPin.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationManager.customPin[i].coordinate
            annotation.title = locationManager.customPin[i].title
            let overlay = MKCircle(center: locationManager.customPin[i].coordinate, radius: 20)
            mapView.addAnnotation(annotation)
            mapView.addOverlay(overlay)
        }
        
        let longTapGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(MapViewCoordinator.tappedOnMap(_:)))
        mapView.addGestureRecognizer(longTapGesture)
        
        // 香椎駅の座標
        let mapRegion = MKCoordinateRegion(center: locationManager.customPin[1].coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(mapRegion, animated: true)
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if showUserLocation {
            if let userLocation = locationManager.userLocation {
                let mapRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
                uiView.setRegion(mapRegion, animated: true)
//                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//                    self.showUserLocation = false
//                }
            }
        }
        // マップの切り替え
        switch mapConfiguration {
        case "Standard":
            let mapType = MKStandardMapConfiguration(elevationStyle: .realistic)
            mapType.showsTraffic = true
            uiView.preferredConfiguration = mapType
        case "Hybrid":
            let mapType = MKHybridMapConfiguration(elevationStyle: .realistic)
            mapType.showsTraffic = true
            uiView.preferredConfiguration = mapType
        case "Imagery":
            let mapType = MKImageryMapConfiguration(elevationStyle: .realistic)
            uiView.preferredConfiguration = mapType
        default:
            break
        }
    }
    
    public func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}
