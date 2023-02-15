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
        
        let identifier = NSStringFromClass(KashiiLineAnnotation.self)
        let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
        if let markerAnnotationView = view as? MKMarkerAnnotationView {
            markerAnnotationView.markerTintColor = .blue
            markerAnnotationView.glyphImage = UIImage(systemName: "checkmark.circle.fill")
            markerAnnotationView.animatesWhenAdded = true
            markerAnnotationView.canShowCallout = true
            
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
//                    parent.checkInAlert = true
                    parent.checkInNumber = i
                    print("KashiiLine annotation accessory view")
                    print(i)
                }
            }
        }
    }
    
    public func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKCircle.self) {
            let circleRenderer = MKCircleRenderer(overlay: overlay)
            circleRenderer.fillColor = .blue.withAlphaComponent(0.1)
            circleRenderer.strokeColor = .blue
            circleRenderer.lineWidth = 1
            return circleRenderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}

class KashiiLineAnnotation: NSObject, MKAnnotation {
    @objc dynamic var coordinate = CLLocationCoordinate2D(latitude: 33.8216217, longitude: 130.6595216)
    var title: String? = NSLocalizedString("SAN_FRANCISCO_TITLE", comment: "SF annotation")
    var subtitle: String? = NSLocalizedString("SAN_FRANCISCO_SUBTITLE", comment: "SF annotation")
}

class CoustomMKPointAnnotation: MKPointAnnotation {
    var pinColor: UIColor = UIColor.black
    var pinPhoto: UIImageView = UIImageView(image: UIImage(systemName: "apple.logo"))
}
