//
//  WorkoutDataHelper.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation

enum Units: Int {
    case metric
    case imperialUK
    case imperialUS
}

enum WorkoutType: Int {
    case run
    case bike
    case walk
}

enum Map: Int {
    case standard
    case hybrid
    case satellite
}

enum Voice: Int {
    case off
    case on
}

enum Milestones: Int {
    case off
    case half
    case one
    case two
    case three
    case four
    case five
    case ten
}

let keyUnit = "UNITS"
let keyWorkout = "WORKOUT"
let keyMap = "MAP"
let keyVoice = "VOICE"
let keyMilestones = "VOICE MILESTONES"

class WorkoutDataHelper {


// MARK: Settings getters
    // Converts the altitude from meter to correct distance unit depending on settings
    // Returns the converted distance string with the associated unit string
    // E.g. "3 km" or "3 miles"
    static func getCompleteDisplayedAltitude(from altitude: Double) -> String {
        return getCompleteDisplayedDistance(from: altitude, withFormat: "%.0f",
                                            isAltitude: true, withUnit: true,
                                            smallDistances: true)
    }

    // Converts the altitude from meter to correct distance unit depending on settings
    // Returns the converted distance string with the associated unit string
    // E.g. "3 km" or "3 miles"
    static func getDisplayedAltitude(from altitude: Double) -> String {
        return getCompleteDisplayedDistance(from: altitude, withFormat: "%.0f",
                                            isAltitude: true, withUnit: false,
                                            smallDistances: true)
    }

    // Returns the correct altitude unit in String depending on the settings
    static func getAltitudeUnit() -> String {
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
            return "\(LocalizationKey.yards.string)"
        case Units.imperialUS.rawValue:
            return "\(LocalizationKey.feet.string)"
        case Units.metric.rawValue:
            fallthrough
        default:
            return "\(LocalizationKey.meter.string)"
        }
    }

    // Calculates the max speed from the list of Location accumulated during workout
    // Converts the max speed to correct speed unit depending on settings
    // Returns the converted max speed in String
    static func getDisplayedMaxSpeed(locations: [Location]) -> String {
        return String(format:"%.1f", getSpeed(from: getMaxSpeed(locations: locations)))
    }

    // Converts the speed from meter per second to correct speed unit depending on settings
    // Returns the converted speed string with the associated unit string
    // E.g. "3.0 km/h" or "3.0 mph"
    static func getCompleteDisplayedSpeed(from speed: Double) -> String {
        let convertedSpeed = getDisplayedSpeed(from: speed)
        var displayedSpeed = ""
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
            displayedSpeed = "\(convertedSpeed) \(LocalizationKey.milesPerHour.string)"
        case Units.imperialUS.rawValue:
            displayedSpeed = "\(convertedSpeed) \(LocalizationKey.milesPerHour.string)"
        case Units.metric.rawValue:
            fallthrough
        default:
            displayedSpeed = "\(convertedSpeed) \(LocalizationKey.kmPerHour.string)"
        }
        return displayedSpeed
    }

    // Converts the speed from meter per second to correct speed unit depending on settings
    // Returns the converted speed string
    // E.g. "3.0"
    static func getDisplayedSpeed(from speed: Double) -> String {
        return String(format:"%.1f", getSpeed(from: speed))
    }

    // Returns the correct speed unit in String depending on the settings
    static func getSpeedUnit() -> String {
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
           fallthrough
        case Units.imperialUS.rawValue:
            return "\(LocalizationKey.milesPerHour.string)"
        case Units.metric.rawValue:
            fallthrough
        default:
            return "\(LocalizationKey.kmPerHour.string)"
        }
    }

    // Converts the distance from meter to correct distance unit depending on settings
    // Returns the converted distance string with the associated unit string
    // E.g. "3.0 km" or "3.0 miles"
    // Will return "300 m" instead of "0.3 km"
    static func getCompleteDisplayedDistance(from distance: Double) -> String {
        getCompleteDisplayedDistance(from: distance, withFormat: "%.1f",
                                     isAltitude: false, withUnit: true,
                                     smallDistances: true)
    }

    // Converts the distance from meter to correct distance unit depending on settings
    // Returns the converted distance string with the associated unit string
    // E.g. "3 km" or "3 miles"
    // Will return "300 m" instead of "0.3 km"
    static func getCompleteSpokenDistance(from distance: Double) -> String {
        getCompleteDisplayedDistance(from: distance, withFormat: "%.1f",
                                     isAltitude: false, withUnit: true,
                                     smallDistances: true)
    }

    // Converts the distance from meter to correct distance unit depending on settings
    // Returns the converted distance string in the highest unit: kilometer or miles
    // E.g. "3.0" or "0.3"
    static func getDisplayedDistance(from distance: Double) -> String {
        getCompleteDisplayedDistance(from: distance, withFormat: "%.1f",
                                     isAltitude: false, withUnit: false,
                                     smallDistances: false)
    }

    // Returns the correct distance unit in String depending on the settings
    // Only returns the highest units: kilometer or miles
    static func getDistanceUnit() -> String {
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
           fallthrough
        case Units.imperialUS.rawValue:
            return "\(LocalizationKey.miles.string)"
        case Units.metric.rawValue:
            fallthrough
        default:
            return "\(LocalizationKey.km.string)"
        }
    }

    static func getWorkoutType() -> Int16 {
        var workoutType = retrieveWorkoutTypeSetting()
        if workoutType > WorkoutType.walk.rawValue {
            workoutType = WorkoutType.run.rawValue
            UserDefaults.standard.set(workoutType,
                                      forKey: keyWorkout)
        }
        return Int16(workoutType)
    }

    static func getDisplayWorkoutType(from workoutType: Int) -> String {
        switch workoutType {
        case WorkoutType.run.rawValue:
            return String(describing: WorkoutType.run).capitalized
        case WorkoutType.bike.rawValue:
            return String(describing: WorkoutType.bike).capitalized
        case WorkoutType.walk.rawValue:
            return String(describing: WorkoutType.walk).capitalized
        default:
            return ""
        }
    }

    static func getWorkoutTypeSpokenString() -> String {
        switch retrieveWorkoutTypeSetting() {
        case WorkoutType.run.rawValue:
            return "ran"
        case WorkoutType.bike.rawValue:
            return "biked"
        case WorkoutType.walk.rawValue:
            return "walked"
        default:
            return ""
        }
    }

// MARK: General data helper functions

    // Returns max speed in meter per second
    static func getMaxSpeed(locations: [Location]) -> Double {
        var speedsArray: [Double] = []
        for location in locations {
            if location.speed < 0 {
                speedsArray.append(0.0)
            } else {
                speedsArray.append(location.speed)
            }
        }
        speedsArray.sort(by: >)
        return speedsArray.isEmpty ? 0.0 : speedsArray.first!
    }

    static func sortedLocations(locations: [Location]) -> [Location] {
        let sortedLocations = locations.sorted {
            $0.timestamp!.compare($1.timestamp!) == .orderedAscending
        }
        return sortedLocations
    }

    // Takes in a date and returns the correct formatting in "Hours:Minutes, Day Month Year"
    // E.g. "13:04, 13 Jul 2020"
    static func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm, d MMM y"
        return formatter.string(from: date)
    }

    static func printAllWorkouts() {
        // TEST - fetch and print data
        let workouts = DataManager.shared.workouts()
        print("Number of workouts: \(workouts.count)")
        print(workouts)
        var count = 1
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        workouts.forEach { (workout) in
            print("Workout \(count)")
            print("Duration \(workout.duration)")
            print("Distance \(workout.distance)")
            print("Speed \(workout.speed)")
            print("Average Speed \(workout.averageSpeed)")
            count += 1
            if let workoutLocations = workout.workoutLocations {
                let sortedLocations = WorkoutDataHelper.sortedLocations(locations: workoutLocations.allObjects as! [Location])
                print("Number of locations in workout: \(sortedLocations.count)")
                for location in sortedLocations  {
                    print(" ")
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = dateFormat
                    print(dateFormatterGet.string(from: location.timestamp!))
                    print(location.latitude)
                    print(location.longitude)
                    print(location.distance)
                    print(location.speed)
                }
            }
        }
    }

    static func printAllLocations() {
        let allLocations = DataManager.shared.locations()
        print("Number of locations: \(allLocations.count)")
        var count = 1
        let dateFormat = "yyyy-MM-dd HH:mm:ss"
        allLocations.forEach { (location) in
            print(count)
            count += 1
            let dateFormatterGet = DateFormatter()
            dateFormatterGet.dateFormat = dateFormat
            print(dateFormatterGet.string(from: location.timestamp!))
            print(location.latitude)
            print(location.longitude)
            print(location.distance)
            print(location.speed)
        }
    }
}

// Private functions
extension WorkoutDataHelper {
    // Converts the speed from meter per second to correct speed unit depending on settings
    // Returns the converted speed
    private static func getSpeed(from speed: Double) -> Double {
        var convertedSpeed = 0.0
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
            fallthrough
        case Units.imperialUS.rawValue:
            convertedSpeed = speedInMilesPerHour(from: speed)
        case Units.metric.rawValue:
            fallthrough
        default:
            convertedSpeed = speedInKmPerHour(from: speed)
        }
        return convertedSpeed
    }

    // Converts the distance from meter to correct distance unit depending on settings
    // Returns the converted distance string with or without the associated unit string
    // E.g. "3.0 km" or "3.0 miles"
    // withFormat gives the number of decimal to show "%.1f" for example
    // isAltitude tells if we want to keep to lower units like meters instead of kilometers
    // withUnit: true user wants the unit following the value: "3.0 km"
    //           false no unit following the value: "3.0"
    //
    private static func getCompleteDisplayedDistance(from distance: Double, withFormat: String,
                                             isAltitude: Bool, withUnit: Bool,
                                             smallDistances: Bool) -> String {
        var convertedDistance = 0.0
        var displayedDistance = ""
        var displayedUnit = ""
        switch retrieveUnitSetting() {
        case Units.imperialUK.rawValue:
            convertedDistance = distanceInMiles(from: distance)
            if (convertedDistance < 1 && smallDistances) || isAltitude {
                displayedDistance = String(format:"\(withFormat)", distanceInYard(from: distance))
                displayedUnit = LocalizationKey.yards.string
            } else {
                displayedDistance = String(format:"\(withFormat)", convertedDistance)
                displayedUnit = LocalizationKey.miles.string
            }
        case Units.imperialUS.rawValue:
            convertedDistance = distanceInMiles(from: distance)
            if (convertedDistance < 1 && smallDistances) || isAltitude {
                displayedDistance = String(format:"\(withFormat)", distanceInFeet(from: distance))
                displayedUnit = LocalizationKey.feet.string
            } else {
                displayedDistance = String(format:"\(withFormat)", convertedDistance)
                displayedUnit = LocalizationKey.miles.string
            }
        case Units.metric.rawValue:
            fallthrough
        default:
            convertedDistance = distanceInKm(from: distance)
            if (convertedDistance < 1 && smallDistances) || isAltitude {
                displayedDistance = String(format:"\(withFormat)", distance)
                displayedUnit = LocalizationKey.meter.string
            } else {
                displayedDistance = String(format:"\(withFormat)", convertedDistance)
                displayedUnit = LocalizationKey.km.string
            }
        }
        if withUnit {
            displayedDistance = String("\(displayedDistance) \(displayedUnit)")
        }
        return displayedDistance
    }

    private static func distanceInKm(from meter: Double) -> Double {
        var distance = (meter / 1000) * 10
        distance = distance.rounded(.down)
        distance = distance / 10
        return distance
    }

    private static func distanceInMiles(from meter: Double) -> Double {
        var distance = (meter / 1609.34) * 10
        distance = distance.rounded(.down)
        distance = distance / 10
        return distance
    }

    private static func distanceInFeet(from meter: Double) -> Double {
        return meter * 3.28084
    }

    private static func distanceInYard(from meter: Double) -> Double {
        return meter * 1.09361
    }

    private static func speedInKmPerHour(from meterPerSecond: Double) -> Double {
           return meterPerSecond * 3.6
    }

    private static func speedInMilesPerHour(from meterPerSecond: Double) -> Double {
        return speedInKmPerHour(from: meterPerSecond) / 1.6093
    }

    private static func retrieveUnitSetting() -> Int {
        return UserDefaults.standard.integer(forKey: keyUnit)
    }

    private static func retrieveWorkoutTypeSetting() -> Int {
        return UserDefaults.standard.integer(forKey: keyWorkout)
    }

    private static func retrieveMapSetting() -> Int {
        return UserDefaults.standard.integer(forKey: keyMap)
    }
}
