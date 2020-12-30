//import Foundation
//import MapKit
//import Pyramid
//
//public struct EventQueryItem: Codable {
//  var page: String
//  var pageNumber: String
//  var per: String
//  var perSize: String
//  var lat: String
//  var long: String
//  var distance: String
//  var latValue: String
//  var longValue: String
//  var distanceValue: String
//}
//
//public struct EventResponse: Codable {
//  let items: [Item]
//  let metadata: Metadata
//  
//  // MARK: - Item
//  
//  class Item: NSObject, Codable, Identifiable {
//    
//    required init(id: String, name: String, categories: String, imageUrl: String? = nil, duration: Int, isActive: Bool, conversationsId: String, addressName: String, details: String? = nil, type: String, sponsored: Bool, overlay: Bool, coordinates: [Double], regionRadius: CLLocationDistance? = 1000, createdAt: Date, updatedAt: Date) {
//      self._id = id
//      self.name = name
//      self.categories = categories
//      self.imageUrl = imageUrl
//      self.duration = duration
//      self.isActive = isActive
//      self.conversationsId = conversationsId
//      self.addressName = addressName
//      self.details = details
//      self.type = type
//      self.sponsored = sponsored
//      self.overlay = overlay
//      self.coordinates = coordinates
//      self.regionRadius = regionRadius
//      self.createdAt = createdAt
//      self.updatedAt = updatedAt
//    }
//    
//    static var defint: EventResponse.Item {
//      .init(id: "", name: "", categories: "", duration: 99, isActive: false, conversationsId: "" ,addressName: "", type: "Point", sponsored: false, overlay: false, coordinates: [9.9, 8.0], createdAt: Date(), updatedAt: Date())
//    }
//    
//    var _id, name, categories: String
//    var imageUrl: String?
//    var duration: Int
//    var isActive: Bool
//    var conversationsId: String
//    var addressName: String
//    var details: String?
//    var type: String
//    var sponsored: Bool
//    var overlay: Bool
//    var coordinates: [Double]
//    var regionRadius: CLLocationDistance? = 1000
//    
//    var createdAt: Date
//    var updatedAt: Date
//  }
//}
//
//public struct Metadata: Codable {
//  let per, total, page: Int
//}
//
//extension EventResponse.Item: MKAnnotation  {
//  var coordinate: CLLocationCoordinate2D { location.coordinate }
//  var title: String? { addressName }
//  var location: CLLocation {
//    CLLocation(latitude: coordinates[0], longitude: coordinates[1])
//  }
//  
//  var region: MKCoordinateRegion {
//    MKCoordinateRegion(
//      center: location.coordinate,
//      latitudinalMeters: regionRadius ?? 1000,
//      longitudinalMeters: regionRadius ?? 1000
//    )
//  }
//  
//  var coordinateMongo: CLLocationCoordinate2D {
//    return CLLocationCoordinate2D(latitude: self.coordinate.longitude, longitude: self.coordinate.latitude)
//  }
//  
//  var coordinatesMongoDouble: [Double] {
//    return [coordinates[1], coordinates[0]]
//  }
//  
//  var doubleToCoordinate: CLLocation {
//    return CLLocation.init(latitude: coordinates[0], longitude: coordinates[1])
//  }
//  
//  func distance(_ currentCLLocation: CLLocation) {
//    DispatchQueue.main.async { [weak self] in
//      guard let self = self else { return }
//      currentCLLocation.distance(from: self.location)
//    }
//  }
//  
//}
//
//extension CLLocation {
//  var double: [Double] {
//    return [self.coordinate.latitude, self.coordinate.longitude]
//  }
//}
//
//public enum TestEventAPI {
//  case events(_ query: EventQueryItem)
//}
//
//public var invalidAccessToken = """
//eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdGF0dXMiOjAsImV4cCI6MTYwOTE2MjEyNiwiaWF0IjoxNjA5MTYyMDA2LCJ1c2VySWQiOiI1ZmFiYjA1ZDI0NzBjMTc5MTliM2MwZTIiLCJwaG9uZU51bWJlciI6Iis3OTIxODgyMTIxOSJ9.pwNaHXe_KujEAaM5GcO1Vsnv9pJCNBx8GnAggjOQnKb3DgkCj-nRhlSe3dUZf1gv-s_OfQB0EFVx3C8DviPjoWJKe_XTv4oKxs-keeJfy55uvDF6UZumzSntGggFrcUYYp7bWLuO3RwR-Y7MBGNg23EGmYgOu8pu5KcVKhZSPEY17GnajCnawe1a8dDVhBg_a9rHRZcyfGlljy-PNoHGTNSiA2kNyoXTPYysYT5z3RHlgRiZTDOL5WVvjqC0C3yCRk8iRgn1_l_8M7b_gMzEwhoSQxeaTpp9xwumSFajHCErbTGiqQIW1nxKkAPW8VDGukkIyRWMTZ6rG9waDbBPnw
//"""
//
//public var refreshTokenForInvalidToken = """
//eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmYWJiMDVkMjQ3MGMxNzkxOWIzYzBlMiIsImlhdCI6MTYwOTE2MjAwNiwiZXhwIjoxNjQwNjk4MDA2fQ.MaKcOPQ5bzyHh_LuSNQ_yKGW3Jc-5sYtpPk4_U04D86Nmsa-Alswb2n9b_rs9OscAE4Nsiyo_EYHDd0_VErTpKSqJBZoTIIM0i6KXJ9vN0C1YmrPjMoR-G_JBn4nURq1sHoK2Us9oDc7ayFMYHzh-IN9PZkZnHYUkTj-H_tC28l9PxJcJAagUyn2EqZSzwCmoAtyA6Yu8Oo7UcUfIOJ4cuet2fwGUl6eK8Y4ixQYzlrZfkByhVl7SfBTQck8IJahH0eZgv8CIHau3iGQkLYKhg9jC-415Szxghf0thrMiqsbYYcUNYxqUqPkYqU8K0kGHWWUI14aO6VvH3yoCezkdg
//"""
//
//public let validAccessToken = """
//eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdGF0dXMiOjAsImV4cCI6MTY5NTIyODEwMiwiaWF0IjoxNjA4OTE0NTAyLCJ1c2VySWQiOiI1ZmFiYjA1ZDI0NzBjMTc5MTliM2MwZTIiLCJwaG9uZU51bWJlciI6Iis3OTIxODgyMTIxOSJ9.Q9iP6VihNsDxshTns-hnXP9Ux6k6vhpZTlZ2c7b0hQVVR1wFre-trODMGvYsLJEonRU23P7wJGO3-KLluh-SeOwQK4mUJo4SzKlAUT4aWME3YDDRaNqpkF6HDIBs9OKsG2Fmr-Z_wTy-R2szGP7aD_lJDDvqRVufcYyEMpqjDj9JDk0xsDKsRlv-iePmYbjBMckNhPzNSPauGrL1hyowPavalD96zEyrAuPL26eBzT5EFlOBCe7xjc_Sn6qZVW1j-LKJmHfKLUaaqPJIL43M0KZuOxmzuI1zb2Agf9OPI17sEYCAB6vFK5sd0EiWxlklK--k53Vg7TKBIXJ6xc-O5g
//""" // valid
//
//public let refreshToken =  """
//eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IjVmYWJiMDVkMjQ3MGMxNzkxOWIzYzBlMiIsImlhdCI6MTYwODkxMTc5NCwiZXhwIjoxNjQwNDQ3Nzk0fQ.fdNIXvJ9OtkCZqG07INRbbX8c5uwQTkK6gYDfVV55Kf0ACrgi5bVfhtXetX3kXIU3gR2mUVSjGh2t-QXjtYIdKX4EQSyh9sDOZtMOM0K0O1M85s3nmPFOtDXs67pZfX2G97IUiGNsIyWrAF82Vk7BOC2bYbmiuSw289W4xspXvQGB6Kw7YBLU3zpTW9VxCmzqZ-NyWsmmtfz_EaPa7fQSw9NqUrg6mX8iv2dI8_VUUOBDAyIF6fU9z1cdZZFQb01aNy5Jz7F5oVIKwZ0oJ8x7jBYZGs843F4pNfHEuwyPFb15aQWUue152BLIyJQO4YmLLyFWDs5BfT0Ak9Zh654pQ
//""" // valid
//
//
//
//extension String {
//  static var empty: String { return "" }
//}
