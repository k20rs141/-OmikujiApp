import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager.shared
    @Binding var checkInAlert: Bool
    @Binding var checkInNumber: Int
    
    public typealias UIViewType = MKMapView
    var mapView = MKMapView()
    
    public func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "KashiiLineAnnotation")
        mapView.selectableMapFeatures = [.pointsOfInterest]
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        
        for i in 0 ..< locationManager.customPin.count {
            let annotation = MKPointAnnotation()
            annotation.coordinate = locationManager.customPin[i].coordinate
            annotation.title = locationManager.customPin[i].title
            let overlay = MKCircle(center: locationManager.customPin[i].coordinate, radius: 3)
            mapView.addAnnotation(annotation)
            mapView.addOverlay(overlay)
        }
        
        if let userLocation = locationManager.userLocation {
            let mapRegion = MKCoordinateRegion(center: userLocation.coordinate, latitudinalMeters: 100, longitudinalMeters: 100)
            mapView.setRegion(mapRegion, animated: true)
        }
        return mapView
    }
    
    public func updateUIView(_ uiView: MKMapView, context: UIViewRepresentableContext<MapView>) {
        if let userLocation = locationManager.userLocation {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            uiView.setRegion(region, animated: false)
        }
    }
    
    public func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(parent: self)
    }
}
