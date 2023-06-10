import SwiftUI

struct StampCollectionView: View {
    @Environment(\.dismiss) private var dismiss
    var locationManager: LocationManager
    
    let screen = UIScreen.main.bounds
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 60)), count: 3)
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    VStack {
                        
                    }
                    .frame(width: screen.width, height: screen.height * 0.3)
                    .background(.blue)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(locationManager.customPin) { symbol in
                            VStack {
                                Image(symbol.checked ? symbol.image : "JRKyusyuApp")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                                    .opacity(symbol.checked ? 1 : 0.4)
                                Text(symbol.title)
                                    .font(.callout)
                                    .fontWeight(.bold)
                            }
                            .frame(width: screen.width * 0.3, height: screen.height * 0.165)
                        }
                    }
                }
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PopUpViewColor"))
            HStack {
                VStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .fontWeight(.bold)
                            .buttonStyle(color: .gray, cornerRadius: 50)
                    }
                    Spacer()
                }
                .padding(.leading)
                Spacer()
            }
            .padding(.top)
        }
    }
}

#Preview {
    StampCollectionView(locationManager: LocationManager())
}
