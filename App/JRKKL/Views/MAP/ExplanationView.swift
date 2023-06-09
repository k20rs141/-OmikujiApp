import SwiftUI
// マップの各設定を解説した画面
struct ExplanationView: View {
    @ObservedObject var locationManager: LocationManager
    @Binding var explanationView: Bool
    @Binding var title: Int

    let screen = UIScreen.main.bounds
    
    var body: some View {
        VStack(spacing: 0) {
            Text(locationManager.information[title].title)
                .foregroundColor(.gray)
                .font(.title)
                .fontWeight(.bold)
            ScrollView {
                Text(locationManager.information[title].detail)
                    .foregroundColor(.gray)
                    .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: screen.height * 0.14)
            .padding(.vertical)
            HStack {
                Button {
                    explanationView = false
                } label: {
                    Text("確認")
                        .foregroundColor(.black)
                        .font(.title)
                        .fontWeight(.bold)
                }
            }
        }
        .frame(maxWidth: screen.width * 0.85, maxHeight: screen.height * 0.3)
        .background(.white)
        .cornerRadius(15)
        .padding(.horizontal)
    }
}

#Preview {
    ExplanationView(locationManager: LocationManager(), explanationView: .constant(true), title: .constant(0))
}
