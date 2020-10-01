//
//  MapViewHellper.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-09-30.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation

class MapViewHellper {
    
    static func getVersion () -> String {
        //First get the nsObject by defining as an optional anyObject
        let nsObject: AnyObject? = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as AnyObject?

        //Then just cast the object as a String, but be careful, you may want to double check for nil
        let version = nsObject as! String
        return version
    }
    
    static func checkProfile () -> Bool {
        var  profileFilledOut = false
        
        if UserDefaults.standard.object(forKey: "AGE") == nil || UserDefaults.standard.object(forKey: "GENDER") == nil || UserDefaults.standard.object(forKey: "WEIGHT") == nil || UserDefaults.standard.object(forKey: "HEIGHT") == nil || UserDefaults.standard.string(forKey: "AGE") == "" || UserDefaults.standard.string(forKey: "GENDER") == "" || UserDefaults.standard.string(forKey: "WEIGHT") == "" || UserDefaults.standard.string(forKey: "HEIGHT") == ""{
        } else {
            profileFilledOut = true
            WatchConnectivity.shared.isProfileFilledOut = true
            WatchConnectivity.shared.interactiveMessage()
        }
        return profileFilledOut
    }
    
    //reset variables for workout
    static func resetVariables () {
        HealthData.shared.totalSteps = 0
        HealthData.shared.totalCaloriesBurned = 0
        HealthData.shared.heartRate = 0
        DeviceMotion.shared.steps = 0
        DeviceMotion.shared.distance = 0
        WatchConnectivity.shared.timeCurrent = "00:00:00"
        WatchConnectivity.shared.distance = "0.0"
        WatchConnectivity.shared.distanceUnit = ""
        WatchConnectivity.shared.speed = "0.0"
        WatchConnectivity.shared.avgSpeed = "0.0"
        WatchConnectivity.shared.speedUnit = ""
        WatchConnectivity.shared.steps = "0"
        WatchConnectivity.shared.calories = "0"
        WatchConnectivity.shared.paddles = "0"
        WatchConnectivity.shared.heartRate = "0"
        WatchConnectivity.shared.interactiveMessage()
    }
    
    static func sectionWorkout(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return "WALK"
        case 1:
            return "RUN"
        case 2:
            return "BIKE"
        case 3:
            return "PADDLE"
        default:
            return "WALK"
        }
    }
    
    static func setWorkoutType () {
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: "WORKOUT") == nil  {
            defaults.set("0", forKey: "WORKOUT")
        }
    }
    
    
    static func cards(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return firstCard
        case 1:
            return secondCard
        case 2:
            return thirdCard
        case 3:
            return fourthCard
        default:
             return firstCard
        }
    }
    
    static func updatesLabelDependsOnWorkoutType (label: String) -> String {
        var label = label
        if WorkoutDataHelper.getWorkoutType() == 3 && label == "STEPS" {
            label = "PADDLES"
        } else if (WorkoutDataHelper.getWorkoutType() == 0 && label == "PADDLES") || (WorkoutDataHelper.getWorkoutType() == 1 && label == "PADDLES") {
            label = "STEPS"
        } else if (WorkoutDataHelper.getWorkoutType() == 2 && label == "PADDLES") || (WorkoutDataHelper.getWorkoutType() == 2 && label == "STEPS") {
            label = "HEART RATE"
        }
        return label
    }
    
    static func updateAllLabels (label: String)  -> [String] {
        let label = updatesLabelDependsOnWorkoutType(label: label)
        var data: [String] = ["",""]
        if label == "TIME" {
            data[0] = "00:00:00"
            data[1] = "TIME"
        }
        if label == "DISTANCE" {
            data[0] = "0.0"
            data[1] = "DISTANCE, \(WorkoutDataHelper.getDistanceUnit())"
        }
        if label == "SPEED" {
            data[0] = "0.0"
            data[1] = "SPEED, \(WorkoutDataHelper.getSpeedUnit())"
        }
        if label == "AVG SPEED" {
            data[0] = "0.0"
            data[1] = "AVG SPEED, \(WorkoutDataHelper.getSpeedUnit())"
        }
        if label == "PADDLES" {
            data[0] = "0"
            data[1] = "PADDLES"
        }
        if label == "STEPS" {
            data[0] = "0"
            data[1] = "STEPS"
        }
        if label == "HEART RATE" {
            data[0] = "0"
            data[1] = "HEART RATE, bpm"
        }
        if label == "CALLORIES" {
            data[0] = "0"
            data[1] = "CALLORIES, kcal"
        }
        return data
    }
    
}
