import SwiftUI
import MapKit

struct LookAroundView: UIViewControllerRepresentable {
    
    typealias UIViewControllerType = MKLookAroundViewController
    
    @Binding var tappedlocation: CLLocationCoordinate2D?
    @Binding var showLookAroundView: Bool
    
    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        MKLookAroundViewController()
    }
    
    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
        if let tappedlocation {
            Task {
                if let scene = await getScene(tappedLocation: .init(latitude: tappedlocation.latitude, longitude: tappedlocation.longitude)) {
                    withAnimation {
                        self.showLookAroundView = true
                        uiViewController.scene = scene
                    }
                } else {
                    withAnimation {
                        self.showLookAroundView = false
                    }
                }
            }
        }
    }
    
    func getScene(tappedLocation: CLLocationCoordinate2D?) async -> MKLookAroundScene? {
        if let latitude = tappedLocation?.latitude, let longitude = tappedLocation?.longitude {
            let sceneRequest = MKLookAroundSceneRequest(coordinate: .init(latitude: latitude, longitude: longitude))
            
            do {
                return try await sceneRequest.scene
            } catch {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
}

struct LookAroundView_Preview: PreviewProvider {
    static var previews: some View {
        LookAroundView(tappedlocation: .constant(CLLocationCoordinate2D(latitude: 37.33062, longitude: -122.01442)), showLookAroundView: .constant(true))
    }
}
