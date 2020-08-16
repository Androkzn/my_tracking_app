//
//  WorkoutDataHelperTests.swift
//  my_tracking_appTests
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import XCTest
import CoreLocation

@testable import my_tracking_app

class WorkoutDataHelperTests: XCTestCase {

    func testCompleteDisplayedAltitude() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "300 m")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0 m")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "2000 m")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: -3)
        XCTAssertEqual(altitude, "-3 m")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "328 yd")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0 yd")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "2187 yd")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: -345)
        XCTAssertEqual(altitude, "-377 yd")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "984 ft")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0 ft")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "6562 ft")
        altitude = WorkoutDataHelper.getCompleteDisplayedAltitude(from: -345)
        XCTAssertEqual(altitude, "-1132 ft")
    }

    func testDisplayedAltitude() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var altitude = WorkoutDataHelper.getDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "300")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "2000")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: -3)
        XCTAssertEqual(altitude, "-3")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "328")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "2187")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: -345)
        XCTAssertEqual(altitude, "-377")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 300)
        XCTAssertEqual(altitude, "984")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 0)
        XCTAssertEqual(altitude, "0")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: 2000)
        XCTAssertEqual(altitude, "6562")
        altitude = WorkoutDataHelper.getDisplayedAltitude(from: -345)
        XCTAssertEqual(altitude, "-1132")
    }

    func testCompleteDisplayedDistance() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "300.0 m")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0 m")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "2.0 km")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "328.1 yd")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0 yd")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "1.2 mi")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "984.3 ft")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0 ft")
        distance = WorkoutDataHelper.getCompleteDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "1.2 mi")
    }

    func testDisplayedDistance() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var distance = WorkoutDataHelper.getDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "0.3")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 950)
        XCTAssertEqual(distance, "0.9")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 960)
        XCTAssertEqual(distance, "0.9")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "2.0")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        distance = WorkoutDataHelper.getDisplayedDistance(from: 1540)
        XCTAssertEqual(distance, "0.9")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "0.1")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "1.2")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        distance = WorkoutDataHelper.getDisplayedDistance(from: 300)
        XCTAssertEqual(distance, "0.1")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 0)
        XCTAssertEqual(distance, "0.0")
        distance = WorkoutDataHelper.getDisplayedDistance(from: 2000)
        XCTAssertEqual(distance, "1.2")
    }

    func testCompleteDisplayedSpeed() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "1080.0 km/h")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0 km/h")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "97.2 km/h")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "671.1 mph")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0 mph")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "60.4 mph")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "671.1 mph")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0 mph")
        speed = WorkoutDataHelper.getCompleteDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "60.4 mph")
    }

    func testDisplayedSpeed() {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var speed = WorkoutDataHelper.getDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "1080.0")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "97.2")

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        speed = WorkoutDataHelper.getDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "671.1")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "60.4")

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        speed = WorkoutDataHelper.getDisplayedSpeed(from: 300)
        XCTAssertEqual(speed, "671.1")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 0)
        XCTAssertEqual(speed, "0.0")
        speed = WorkoutDataHelper.getDisplayedSpeed(from: 27)
        XCTAssertEqual(speed, "60.4")
    }

    func testWorkoutType() {
        UserDefaults.standard.set(WorkoutType.walk.rawValue, forKey: "WORKOUT")
        print("WorkoutType.walk.rawValue \(WorkoutType.walk.rawValue)")
        var type = WorkoutDataHelper.getWorkoutType()
        XCTAssertEqual(type, Int16(WorkoutType.walk.rawValue))

        UserDefaults.standard.set(WorkoutType.run.rawValue, forKey: "WORKOUT")
        print("WorkoutType.walk.rawValue \(WorkoutType.run.rawValue)")
        type = WorkoutDataHelper.getWorkoutType()
        XCTAssertEqual(type, Int16(WorkoutType.run.rawValue))

        UserDefaults.standard.set(WorkoutType.bike.rawValue, forKey: "WORKOUT")
        print("WorkoutType.walk.rawValue \(WorkoutType.bike.rawValue)")
        type = WorkoutDataHelper.getWorkoutType()
        XCTAssertEqual(type, Int16(WorkoutType.bike.rawValue))
        
        UserDefaults.standard.set(WorkoutType.paddle.rawValue, forKey: "WORKOUT")
        print("WorkoutType.walk.rawValue \(WorkoutType.paddle.rawValue)")
        type = WorkoutDataHelper.getWorkoutType()
        XCTAssertEqual(type, Int16(WorkoutType.paddle.rawValue))

        UserDefaults.standard.set(34, forKey: "WORKOUT")
        type = WorkoutDataHelper.getWorkoutType()
        XCTAssertEqual(type, Int16(WorkoutType.walk.rawValue))
    }

    func testDisplayedMaxSpeed() {
        let workout = DataManager.shared.workout(timestamp: Date())
        let cllocation = CLLocation(latitude: 49.2827, longitude: -123.1207)
        let cllocation1 = CLLocation(latitude: 49.283883, longitude: -123.118147)
        let location = DataManager.shared.location(timestamp: Date(), distance: 10, latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude, speed: 3, altitude: 0, workout: workout)
        let location1 = DataManager.shared.location(timestamp: Date(), distance: 10, latitude: cllocation1.coordinate.latitude, longitude: cllocation1.coordinate.longitude, speed: 45, altitude: 0, workout: workout)
        let location2 = DataManager.shared.location(timestamp: Date(), distance: 10, latitude: cllocation.coordinate.latitude, longitude: cllocation.coordinate.longitude, speed: 10, altitude: 0, workout: workout)
        let location3 = DataManager.shared.location(timestamp: Date(), distance: 10, latitude: cllocation1.coordinate.latitude, longitude: cllocation1.coordinate.longitude, speed: 54, altitude: 0, workout: workout)
        let locations = [location, location1, location2, location3]

        UserDefaults.standard.set(Units.metric.rawValue, forKey: "UNITS")

        var speedString = WorkoutDataHelper.getDisplayedMaxSpeed(locations: locations)
        XCTAssertEqual(speedString, "194.4")
        var speed = WorkoutDataHelper.getMaxSpeed(locations: locations)
        XCTAssertEqual(speed, 54.0)

        UserDefaults.standard.set(Units.imperialUK.rawValue, forKey: "UNITS")

        speedString = WorkoutDataHelper.getDisplayedMaxSpeed(locations: locations)
        XCTAssertEqual(speedString, "120.8")
        speed = WorkoutDataHelper.getMaxSpeed(locations: locations)
        XCTAssertEqual(speed, 54.0)

        UserDefaults.standard.set(Units.imperialUS.rawValue, forKey: "UNITS")

        speedString = WorkoutDataHelper.getDisplayedMaxSpeed(locations: locations)
        XCTAssertEqual(speedString, "120.8")
        speed = WorkoutDataHelper.getMaxSpeed(locations: locations)
        XCTAssertEqual(speed, 54.0)

        DataManager.shared.resetAllRecords(in: "Workout")
        DataManager.shared.resetAllRecords(in: "Location")
    }
}
