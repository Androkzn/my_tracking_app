//
//  WatchConnectivity.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-09-29.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivity: NSObject, WCSessionDelegate {
    
    static let shared  = WatchConnectivity()
    
    var isiOSAppOpened = false
    var isProfileFilledOut = false
    var isTrackingStarted = false
    
    var workoutType = 0
    var timeCurrent = "00:00:00"
    var distance = "0.0"
    var distanceUnit = ", km"
    var speed = "0.0"
    var avgSpeed = "0.0"
    var speedUnit = ", km/h"
    var steps = "0"
    var calories = "0"
    var paddles = "0"
    var heartRate = "0"
    
    var message: [String: Any] { return["WorkoutType": workoutType, "Time": timeCurrent, "isTrackingStarted": isTrackingStarted, "Distance": distance, "DistanceUnit": distanceUnit, "Speed": speed, "AvgSpeed": avgSpeed, "SpeedUnit": speedUnit, "Steps": steps, "Calories": calories, "Paddles": paddles, "HeartRate": heartRate, "iOSOpened": isiOSAppOpened, "isProfileFilledOut": isProfileFilledOut]}
    
    var session = WCSession.default
    

    func setUpWatchConectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    func interactiveMessage() {
        workoutType = Int(WorkoutDataHelper.getWorkoutType())
        session.sendMessage(message, replyHandler: nil, errorHandler: nil)
    }
    
    //MARK: - Delegate Watch Conectivity
        func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
               switch activationState{
               case .activated:
                   print("Phone WCSEssion Activated")
               case .notActivated:
                   print("Phone WCSEssion NOT Activated")
               case .inactive:
                   print("Phone WCSEssion Inactive")
               @unknown default:
                   print("ERROR")
            }
        }

        func sessionDidBecomeInactive(_ session: WCSession) {
            print("Session went inactive")
            NotificationCenter.default
                               .post(name:           NSNotification.Name("isWatchPaired"),
                                object: nil)
        }

        func sessionDidDeactivate(_ session: WCSession) {
           print("Session deactivated")
           NotificationCenter.default
                               .post(name:           NSNotification.Name("isWatchPaired"),
                                object: nil)
        }
        
        func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
            if let pressStart = message["PressStart"] as? Bool {
                if pressStart {
                    if !isTrackingStarted {
                        DispatchQueue.main.async {
                             MapViewController.isStartButtonPressedRemoutely = pressStart
                            NotificationCenter.default
                            .post(name:           NSNotification.Name("pressStartButton"),
                             object: nil)
                        }
                    } else {
                        DispatchQueue.main.async {
                            MapViewController.isStartButtonPressedRemoutely = pressStart
                            NotificationCenter.default
                            .post(name:           NSNotification.Name("pressStopButton"),
                             object: nil)
                        }
                    }
                }
            }
            if let workoutTypeFromWatch = message["WorkoutType"] as? Int {
                DispatchQueue.main.async {
                    print(workoutTypeFromWatch)
                    UserDefaults.standard.set(workoutTypeFromWatch, forKey: "WORKOUT")
                     NotificationCenter.default
                                               .post(name:           NSNotification.Name("updateWorkoutTypeIcon"),
                                                object: nil)
                    self.interactiveMessage()
                }
            }
            
            replyHandler(message)
            //print("pressStart: \(MapViewController.isStartButtonPressedRemoutely)")
        }
}
    
