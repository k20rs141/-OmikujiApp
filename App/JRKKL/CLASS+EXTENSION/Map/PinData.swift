import Foundation
import MapKit

struct PinData: Identifiable, Codable {
    let id = UUID()

    var title: String
    var latitude: Double
    var longitude: Double
    var category: String
    var checked: Bool

    enum CodingKeys: String, CodingKey {
        case title
        case latitude
        case longitude
        case category
        case checked
    }
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
