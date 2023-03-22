import SwiftUI

struct CheckInView: View {
    @ObservedObject var locationManager: LocationManager
    @State private var notificationButton = false
    @Binding var checkInView: Bool
    @Binding var checkInNumber: Int
    
    let screen = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack {
                    Image("\(locationManager.customPin[checkInNumber].image)_station")
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: 75, maxHeight: 75)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                }
                .frame(maxWidth: screen.width * 0.25, maxHeight: .infinity)
                ZStack {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(locationManager.customPin[checkInNumber].title)
                            .font(.title2)
                        Text(locationManager.address)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                    .foregroundColor(.black)
                    VStack {
                        Button {
                            notificationButton.toggle()
                            Haptics.lightImpact()
                        } label: {
                            Text("通知ON")
                                .foregroundColor(notificationButton ? .white : Color("JRKyusyuColor"))
                                .font(.caption)
                                .frame(maxWidth: screen.width * 0.2, maxHeight: screen.height * 0.038)
                                .background(notificationButton ? Color("JRKyusyuColor") : .clear)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(lineWidth: 1)
                                        .foregroundColor(Color("JRKyusyuColor"))
                                )
                                .padding(.trailing)
                                .padding(.top)
                        }
                        .onChange(of: notificationButton) { _ in
                            if notificationButton {
                                locationManager.moniteringStart(moniteringNumber: checkInNumber)
                                locationManager.requestState(moniteringNumber: checkInNumber)
                            } else {
                                locationManager.moniteringStop(moniteringNumber: checkInNumber)
                            }
                            UserDefaults.standard.set(notificationButton, forKey: "notificationButton\(checkInNumber)")
                        }
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .trailing)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Button {
                    if !locationManager.customPin[checkInNumber].checked {
                        locationManager.checkLocation(checkInNumber: checkInNumber)
                    }
                } label: {
                    Text(locationManager.customPin[checkInNumber].checked ? "チェックイン済み" : "チェックイン")
                        .foregroundColor(.white)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.045)
                        .background(Color("JRKyusyuColor"))
                        .opacity(locationManager.customPin[checkInNumber].checked ? 0.6 : 1)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: screen.height * 0.065)
        }
        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.17)
        .background(Color("PopUpViewColor"))
        .cornerRadius(15)
        .padding(.horizontal)
        .onChange(of: checkInView) { _ in
            if checkInView {
                let notificationButton = UserDefaults.standard.bool(forKey: "notificationButton\(checkInNumber)")
                self.notificationButton = notificationButton
            }
        }
        .alert("チェックイン範囲外です。範囲内に移動してください!", isPresented: $locationManager.checkInAlert) {
            Button("OK") { 
            }
        }
        .sheet(isPresented: $locationManager.isAnimation) {
            AnimationView(locationManager: locationManager, checkInNumber: $checkInNumber)
        }
    }
}

struct CheckInView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckInView(locationManager: LocationManager(), checkInView: .constant(false), checkInNumber: .constant(0))
    }
}
