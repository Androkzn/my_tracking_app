//
//  LocalizationKey.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation

enum LocalizationKey: String {
    case kmPerHour = "km/h"
    case milesPerHour = "mph"
    case km = "km"
    case meter = "m"
    case miles = "mi"
    case yards = "yd"
    case feet = "ft"

    var string: String {
        return rawValue
    }
}
