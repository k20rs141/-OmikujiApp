import SwiftUI

struct CheckInView: View {
    @ObservedObject var locationManager: LocationManager
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
                VStack(alignment: .leading, spacing: 10) {
                    Text(locationManager.customPin[checkInNumber].title)
                        .font(.title2)
                    Text("福岡県福岡市東区")
                        .font(.caption)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
                VStack(alignment: .leading) {
                    Text("自動アラート")
                        .foregroundColor(Color("JRKyusyuColor"))
                        .font(.caption)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.035)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                            .stroke(lineWidth: 1)
                            .foregroundColor(Color("JRKyusyuColor"))
                        )
                        .padding(.trailing)
                }
                .frame(maxWidth: screen.width * 0.3, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            HStack {
                Button {
                    locationManager.checkLocation(checkInNumber: checkInNumber)
                } label: {
                    Text("チェックイン")
                        .foregroundColor(.white)
                        .font(.callout)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.045)
                        .background(Color("JRKyusyuColor"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: screen.height * 0.055)
        }
        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.17)
        .background(Color("PopUpViewColor"))
        .cornerRadius(15)
        .padding(.horizontal)
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
