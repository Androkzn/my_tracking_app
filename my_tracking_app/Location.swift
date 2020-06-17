//
//  Location.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation

struct Location {

    var timestamp: Date
    var longitude: Double = 0.0
    var latitude: Double = 0.0

    init (timestamp: Date, longitude: Double, latitude: Double) {
        self.timestamp = timestamp
        self.longitude = longitude
        self.latitude = latitude
    }
}
