import MapKit
import SwiftUI

final class MapViewCoordinator: NSObject {
    private var parent: MapView

    init(parent: MapView) {
        self.parent = parent
    }
}

extension MapViewCoordinator: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // 現在地はannotationは変更しない(青いマークのままにする)
        if (annotation is MKUserLocation) { return nil }
        
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: "KashiiLineAnnotation", for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            for i in 0 ..< parent.locationManager.customPin.count {
                if view.annotation?.title?!.applyingTransform(.fullwidthToHalfwidth, reverse: false) == parent.locationManager.customPin[i].title.applyingTransform(.fullwidthToHalfwidth, reverse: false) {
                    markerAnnotationView.markerTintColor = parent.locationManager.customPin[i].checked ? .red : UIColor(named: "Jrq2ndColor")
                    markerAnnotationView.glyphImage = UIImage(systemName: "checkmark.circle.fill")
                    markerAnnotationView.glyphTintColor = UIColor(.white)
                    markerAnnotationView.animatesWhenAdded = true
                    markerAnnotationView.canShowCallout = true
                }
            }
            
            markerAnnotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        return view
    }
    
    public func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let annotation = view.annotation as? MKMapFeatureAnnotation {
            print("annotation: \(annotation)")
        } else {
            for i in 0 ..< parent.locationManager.customPin.count {
                if view.annotation?.title?!.applyingTransform(.fullwidthToHalfwidth, reverse: false) == parent.locationManager.customPin[i].title.applyingTransform(.fullwidthToHalfwidth, reverse: false) {
                    parent.checkInView = true
                    parent.checkInNumber = i
                    // 逆ジオコーディング
                    parent.locationManager.reverseGeocoding(checkInNumber: i)
                    print("KashiiLine annotation accessory view")
                    print(i)
                }
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = UIColor(named: "Jrq2ndColor")?.withAlphaComponent(0.4)
            circleRenderer.strokeColor = UIColor(named: "Jrq2ndColor")
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    @objc func tappedOnMap(_ sender: UILongPressGestureRecognizer) {
        guard let mapView = sender.view as? MKMapView else { return }
        
        let touchLocation = sender.location(in: sender.view)
        let locationCoordinate = mapView.convert(touchLocation, toCoordinateFrom: sender.view)
        let impactHeavy = UIImpactFeedbackGenerator(style: .medium)
        impactHeavy.impactOccurred()
        parent.tappedLocation = locationCoordinate
    }
}
