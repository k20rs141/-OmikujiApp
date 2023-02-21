import SwiftUI
import EffectsLibrary

struct AnimationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    @State private var wish = false
    @State private var finishWish = false
    @Binding var checkInNumber: Int
    
    let screen = UIScreen.main.bounds
    var config = FireworksConfig(
        backgroundColor: .black.opacity(0.4),
        intensity: .medium,
        lifetime: .short,
        initialVelocity: .fast,
        fadeOut: .slow
    )
    
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
                            .offset(x: 0, y: 70)
                    }
                }
            }
            FireworksView(config: config)
                .opacity(wish && !finishWish ? 1 : 0)
                .ignoresSafeArea()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                doAnimation()
            }
        }
    }
    
    func doAnimation() {
        withAnimation(.spring()) {
            wish = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 1.0)) {
                finishWish = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                wish = false
                finishWish = false
            }
        }
    }
}

struct AnimationView_Previews: PreviewProvider {
    static var previews: some View {
        AnimationView(locationManager: LocationManager(), checkInNumber: .constant(1))
    }
}
