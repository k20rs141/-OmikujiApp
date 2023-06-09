import SwiftUI
import ConfettiSwiftUI

struct AnimationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    @State private var confettiCounter = 0
    @Binding var checkInNumber: Int
    
    let screen = UIScreen.main.bounds
    
    var body: some View {
        ZStack {
            VStack {
                VStack {
                    Image(locationManager.customPin[checkInNumber].image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: screen.width * 0.8, height: screen.width * 0.8)
                }
                .frame(width: screen.width * 0.9, height: screen.height * 0.35)
                .cornerRadius(20)
                .offset(x: 0, y: -20)
                VStack {
                    Text("スタンプ獲得！")
                        .foregroundColor(.red)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("\(locationManager.customPin[checkInNumber].title)に到着")
                        .font(.title)
                    Button {
                        dismiss()
                    } label: {
                        Text("閉じる")
                            .foregroundColor(.white)
                            .font(.callout)
                            .fontWeight(.bold)
                            .frame(width: screen.width * 0.30, height: screen.height * 0.05)
                            .background(.red)
                            .cornerRadius(25)
                    }
                    .offset(x: 0, y: 70)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            VStack {
                ConfettiCannon(counter: $confettiCounter, num: 100, openingAngle: Angle(degrees: 65), closingAngle: Angle(degrees: 90), radius: 800.0)
            }
            .offset(x: screen.width * -0.45, y: screen.height * 0.45)
            VStack {
                ConfettiCannon(counter: $confettiCounter, num: 100, openingAngle: Angle(degrees: 90), closingAngle: Angle(degrees: 105), radius: 800.0)
            }
            .offset(x: screen.width * 0.45, y: screen.height * 0.45)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                confettiCounter = 1
            }
        }
    }
}

#Preview {
    AnimationView(locationManager: LocationManager(), checkInNumber: .constant(1))
}
