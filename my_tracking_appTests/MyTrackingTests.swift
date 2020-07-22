//
//  MyTrackingTests.swift
//  my_tracking_appTests
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import XCTest
import CoreLocation
import CoreData

@testable import my_tracking_app

class MyTrackingTests: XCTestCase {

    var viewController: MapViewController!
    var locationManager: CLLocationManager!

    override func setUp() {
        viewController = (UIStoryboard(name: "Map", bundle: nil).instantiateViewController(withIdentifier: "map") as! MapViewController)
        _ = viewController.view
        locationManager = CLLocationManager()

        DataManager.shared.resetAllRecords(in: "Workout")
        DataManager.shared.resetAllRecords(in: "Location")
    }

    override func tearDown() {
        DataManager.shared.resetAllRecords(in: "Workout")
        DataManager.shared.resetAllRecords(in: "Location")
    }

    func testLocationSaving() throws {
        var countWorkouts = DataManager.shared.workouts().count
        var countLocations = DataManager.shared.locations().count

        let location1 = CLLocation(latitude: 49.2827, longitude: -123.1207)
        let location2 = CLLocation(latitude: 49.283883, longitude: -123.118147)
        let locations = [location2, location1, location2, location1, location2]
        viewController.isTrackingStarted = true
        viewController.lastLocation = location1
        viewController.startWorkout()
        for i in 0..<5 {
            let location = locations[i]
            viewController.locationManager(locationManager, didUpdateLocations: [location])
        }
        viewController.isTrackingStarted = false
        viewController.stopWorkout()

        countWorkouts = DataManager.shared.workouts().count - countWorkouts
        countLocations = DataManager.shared.locations().count - countLocations

        XCTAssertEqual(countWorkouts, 1)
        XCTAssertEqual(countLocations, locations.count + 1)
        XCTAssertNotNil(DataManager.shared.workouts().last!.workoutLocations)
        XCTAssertEqual(DataManager.shared.workouts().last!.workoutLocations!.count, countLocations)
    }
}
