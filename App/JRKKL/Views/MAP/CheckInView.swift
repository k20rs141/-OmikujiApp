import SwiftUI

struct CheckInView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var checkInView: Bool
    @Binding var checkInNumber: Int
    
    let screen = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 0) {
            if (locationManager.customPin.count > 8) {
                ZStack {
                    Text(locationManager.customPin[checkInNumber].title)
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity, maxHeight: screen.height * 0.06)
                        .background(Color("JRKyusyuColor"))
                    HStack {
                        Button {
                            self.checkInView = false
                        } label: {
                            Image(systemName: "xmark")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color("JRKyusyuColor"))
                                .background {
                                    Circle()
                                        .strokeBorder(Color("JRKyusyuColor"),lineWidth: 2)
                                        .background(Circle().foregroundColor(Color("PopUpViewColor")))
                                        .frame(width: 45, height: 45)
                                }
                        }
                        .padding(.leading)
                        Spacer()
                    }
//                    .offset(x: screen.width * -0.37, y: screen.height * -0.015)
                }
                VStack {
                    Spacer()
                    Image(systemName: "mappin.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .foregroundColor(Color("JRKyusyuColor"))
                    Spacer()
                    if locationManager.customPin[checkInNumber].checked {
                        Text("チェックイン済みです")
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.bottom)
                    } else {
                        Button {
                            locationManager.checkLocation(checkInNumber: checkInNumber)
                        } label: {
                            Text("チェックインする")
                                .foregroundColor(.white)
                                .font(.callout)
                                .fontWeight(.bold)
                                .frame(width: screen.width * 0.45, height: screen.height * 0.04)
                                .background(.red)
                                .cornerRadius(25)
                                .padding(.bottom)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                VStack {
                    Button {
                        locationManager.moniteringStart(moniteringNumber: checkInNumber)
                    } label: {
                        Text("開始")
                            .foregroundColor(.white)
                            .font(.callout)
                            .fontWeight(.bold)
                            .frame(width: screen.width * 0.25, height: screen.height * 0.04)
                            .background(.red)
                            .cornerRadius(25)
                            .padding(.bottom)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: screen.height * 0.13)
            }
        }
        .alert("チェックイン範囲外です。範囲内に移動してください!", isPresented: $locationManager.checkInAlert) {
            Button("OK") {
                
            }
        }
        .sheet(isPresented: $locationManager.isAnimation) {
            AnimationView(locationManager: locationManager, checkInNumber: $checkInNumber)
        }
        .frame(width: screen.width * 0.8, height: screen.height * 0.4, alignment: .center)
        .background(Color("PopUpViewColor"))
        .cornerRadius(12)
    }
}

struct CheckInView_Previews: PreviewProvider {
    
    static var previews: some View {
        CheckInView(locationManager: LocationManager(), checkInView: .constant(false), checkInNumber: .constant(0))
    }
}
