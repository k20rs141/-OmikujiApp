import SwiftUI
import MapKit

struct ContentView: View {
    @ObservedObject var locationManager = LocationManager()
    @State private var checkInAlert = false
    @State private var checkInNumber = 0
    
    let screen = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            MapView(checkInAlert: $checkInAlert, checkInNumber: $checkInNumber)
                .ignoresSafeArea()
            LookAroundView()
                .frame(maxWidth: screen.width * 0.5, maxHeight: screen.height * 0.15)
                .cornerRadius(5)
                .padding(.bottom)
                .padding(.leading)
                .offset(x: screen.width * -0.25, y: screen.height * 0.30)
            if checkInAlert == true {
                CheckInView(checkInAleart: $checkInAlert ,checkInNumber: $checkInNumber)
                    .transition(.scale)
                    .animation(.easeInOut.delay(2.0), value: checkInAlert)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
