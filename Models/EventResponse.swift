//
//  EventResponse.swift
//  PyramidTests
//
//  Created by Saroar Khandoker on 30.12.2020.
//

import Foundation
import MapKit

struct EventResponse: Codable {
  let items: [Item]
  let metadata: Metadata
  
  // MARK: - Item
  
  class Item: NSObject, Codable, Identifiable {
    
    required init(id: String, name: String, categories: String, imageUrl: String? = nil, duration: Int, isActive: Bool, conversationsId: String, addressName: String, details: String? = nil, type: String, sponsored: Bool, overlay: Bool, coordinates: [Double], regionRadius: CLLocationDistance? = 1000, createdAt: Date, updatedAt: Date) {
      self._id = id
      self.name = name
      self.categories = categories
      self.imageUrl = imageUrl
      self.duration = duration
      self.isActive = isActive
      self.conversationsId = conversationsId
      self.addressName = addressName
      self.details = details
      self.type = type
      self.sponsored = sponsored
      self.overlay = overlay
      self.coordinates = coordinates
      self.regionRadius = regionRadius
      self.createdAt = createdAt
      self.updatedAt = updatedAt
    }
    
    static var defint: EventResponse.Item {
      .init(id: "", name: "", categories: "", duration: 99, isActive: false, conversationsId: "" ,addressName: "", type: "Point", sponsored: false, overlay: false, coordinates: [9.9, 8.0], createdAt: Date(), updatedAt: Date())
    }
    
    var _id, name, categories: String
    var imageUrl: String?
    var duration: Int
    var isActive: Bool
    var conversationsId: String
    var addressName: String
    var details: String?
    var type: String
    var sponsored: Bool
    var overlay: Bool
    var coordinates: [Double]
    var regionRadius: CLLocationDistance? = 1000
    
    var createdAt: Date
    var updatedAt: Date
  }
}

struct Metadata: Codable {
  let per, total, page: Int
}

extension EventResponse.Item: MKAnnotation  {
  var coordinate: CLLocationCoordinate2D { location.coordinate }
  var title: String? { addressName }
  var location: CLLocation {
    CLLocation(latitude: coordinates[0], longitude: coordinates[1])
  }
  
  var region: MKCoordinateRegion {
    MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius ?? 1000,
      longitudinalMeters: regionRadius ?? 1000
    )
  }
  
  var coordinateMongo: CLLocationCoordinate2D {
    return CLLocationCoordinate2D(latitude: self.coordinate.longitude, longitude: self.coordinate.latitude)
  }
  
  var coordinatesMongoDouble: [Double] {
    return [coordinates[1], coordinates[0]]
  }
  
  var doubleToCoordinate: CLLocation {
    return CLLocation.init(latitude: coordinates[0], longitude: coordinates[1])
  }
  
  func distance(_ currentCLLocation: CLLocation) {
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      currentCLLocation.distance(from: self.location)
    }
  }
  
}

extension CLLocation {
  var double: [Double] {
    return [self.coordinate.latitude, self.coordinate.longitude]
  }
}
