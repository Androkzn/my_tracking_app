//
//  Workout.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//


import Foundation

struct WorkoutObject {
    
    var timestamp: Date
    var duration: Double = 0.0
    var distance: Double = 0.0
    var speed: Double = 0.0
    var averageSpeed: Double = 0.0
    var callories: Int = 0
    var averageCallories: Int = 0
    var bloodOxygen: Int = 0
    var locations: [Location] = []
    
    init (timestamp: Date, duration: Double, distance: Double, speed: Double, averageSpeed: Double, callories: Int, averageCallories: Int, bloodOxygen: Int, locations: [Location] ) {
        self.timestamp = timestamp
        self.duration = duration
        self.speed = speed
        self.averageSpeed = averageSpeed
        self.callories = callories
        self.averageCallories = averageCallories
        self.bloodOxygen = bloodOxygen
        self.locations = locations
      }


}
