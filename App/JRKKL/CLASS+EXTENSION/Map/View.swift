import SwiftUI

extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .frame(width: UIScreen.main.bounds.width * 0.9, height: UIScreen.main.bounds.height * 0.08)
            .background(Color(red: 0.97, green: 0.97, blue: 0.97))
            .cornerRadius(13)
    }
    
    func textStyle() -> some View {
        self
            .foregroundColor(.gray)
            .font(.title3)
            .frame(width: UIScreen.main.bounds.width * 0.33, height: UIScreen.main.bounds.height * 0.07, alignment: .trailing)
    }
    
    func buttonStyle(color: Color, cornerRadius: CGFloat) -> some View {
        self
            .foregroundColor(color)
            .padding()
            .background(.ultraThickMaterial)
            .cornerRadius(cornerRadius)
    }
}
