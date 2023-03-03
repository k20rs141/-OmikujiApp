import SwiftUI

struct StampCollectionView: View {
    @ObservedObject var locationManager = LocationManager()
    
    let screen = UIScreen.main.bounds
    let columns: [GridItem] = Array(repeating: .init(.flexible(minimum: 60)), count: 3)
    
    var body: some View {
        VStack {
            VStack {
                ScrollView {
                    VStack {
                        
                    }
                    .frame(width: screen.width, height: screen.height * 0.25)
                    .background(.blue)
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(locationManager.customPin) { symbol in
                            VStack {
                                Image(symbol.image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 105, height: 105)
                                    .clipShape(Circle())
                                Text(symbol.title)
                                    .font(.callout)
                                    .fontWeight(.bold)
                            }
                            .frame(width: screen.width * 0.3, height: screen.height * 0.16)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color("PopUpViewColor"))
        }
        .background(Color("PopUpViewColor"))
    }
}

struct StampCollectionView_Previews: PreviewProvider {
    static var previews: some View {
        StampCollectionView(locationManager: LocationManager())
    }
}
