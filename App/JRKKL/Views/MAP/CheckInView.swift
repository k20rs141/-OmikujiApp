import SwiftUI

struct CheckInView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager = LocationManager()
    @State private var isPresented = false
    @Binding var checkInAleart: Bool
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
                        Button(action: {
                            self.checkInAleart = false
                        }, label: {
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
                        })
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
                    Button {
                        locationManager.checkLocation(checkInNumber: checkInNumber)
                    } label: {
                        Text("チェックインする")
                            .foregroundColor(.white)
                            .font(.callout)
                            .fontWeight(.bold)
                            .frame(width: screen.width * 0.45, height: screen.height * 0.04)
                            .background(.red)
                            .cornerRadius(50)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                Divider()
                VStack {
                    LookAroundView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(5)
                }
                .frame(maxWidth: .infinity, maxHeight: screen.height * 0.13)
            }
        }
        .onDisappear {
            dismiss()
        }
        .alert("\(locationManager.checkInMessage)", isPresented: $locationManager.checkInAlert, actions: {
            
        })
        .frame(width: screen.width * 0.8, height: screen.height * 0.4, alignment: .center)
        .background(Color("PopUpViewColor"))
        .cornerRadius(12)
    }
}

//struct CheckInView_Previews: PreviewProvider {
//    static var previews: some View {
//        CheckInView(checkInAleart: )
//    }
//}
