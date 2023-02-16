import SwiftUI
import MapKit

struct LookAroundView: View {
    @State private var location: CLLocationCoordinate2D = .init(latitude: 33.65943127, longitude: 130.444117)

    var body: some View {
        VStack {
            LookAround(location: $location)
        }
    }
}

struct LookAround: UIViewControllerRepresentable {
    typealias UIViewControllerType = MKLookAroundViewController
    
    @Binding var location: CLLocationCoordinate2D
    
    func makeUIViewController(context: Context) -> MKLookAroundViewController {
        MKLookAroundViewController()
    }
    
    func updateUIViewController(_ uiViewController: MKLookAroundViewController, context: Context) {
        Task {
            if let scene = await getScene(tappedLocation: .init(latitude: location.latitude, longitude: location.longitude)) {
                withAnimation {
//                        self.showLookAroundView = true
                    uiViewController.scene = scene
                }
            } else {
                withAnimation {
//                        self.showLookAroundView = false
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
        LookAroundTestView()
    }
}
