import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager.shared
    @Binding var checkInView: Bool
    @Binding var checkInNumber: Int
    @Binding var tappedLocation: CLLocationCoordinate2D?
    @Binding var showUserLocation: Bool
    
    public typealias UIViewType = MKMapView
    var mapView = MKMapView()
    var mapType = MKStandardMapConfiguration(elevationStyle: .realistic)
    
    public func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "KashiiLineAnnotation")
        mapView.selectableMapFeatures = [.pointsOfInterest]
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        mapType.showsTraffic = true
        mapView.preferredConfiguration = mapType
        
        mapView.removeAnnotations(mapView.annotations)
        
        for i in 0 ..< locationManager.customPin.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationManager.customPin[i].coordinate
            annotation.title = locationManager.customPin[i].title
            let overlay = MKCircle(center: locationManager.customPin[i].coordinate, radius: 3)
            mapView.addAnnotation(annotation)
            mapView.addOverlay(overlay)
        }
        
        let longTapGesture = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(MapViewCoordinator.tappedOnMap(_:)))
        mapView.addGestureRecognizer(longTapGesture)
        
        // 福岡県の庁舎の座標
        let initLocation = CLLocationCoordinate2D(latitude: 33.60639, longitude: 130.41806)
        let mapRegion = MKCoordinateRegion(center: initLocation, latitudinalMeters: 100, longitudinalMeters: 100)
        mapView.setRegion(mapRegion, animated: true)
        
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if showUserLocation {
            if let userLocation = locationManager.userLocation {
                let mapRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
                uiView.setRegion(mapRegion, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.showUserLocation = false
                }
            }
        }
    }
    
    public func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}
