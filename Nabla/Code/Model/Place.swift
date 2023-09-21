//
//  Place.swift
//  ble-tbt-navigation-ios
//
//  Created by Jaksa Tomovic on 28.08.2023..
//

import Foundation

public var places: [Place] = []

public class Place: Codable {
    
    var id: String
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    
    init(id: String, name: String, address: String, latitude: Double, longitude: Double) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
    }
}
