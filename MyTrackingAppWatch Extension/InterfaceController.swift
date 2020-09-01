//
//  InterfaceController.swift
//  MyTrackingAppWatch Extension
//
//  Created by Andrei Tekhtelev on 2020-08-31.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController, WCSessionDelegate {
    
    @IBOutlet weak var workoutTypeIcon: WKInterfaceImage!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var startButtonLabel: WKInterfaceButton!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateLabels (message: [String: Any]) {
        if let workoutType = message ["WorkoutType"] as? Int {
            updatesWorkoutTypeIcon(workoutType: workoutType)
            startButtonLabel.setTitle(sectionWorkout(atIndex: workoutType))
        }
        if let timeCurrent = message ["Time"] as? String {
            timerLabel.setText(timeCurrent)
        }
    }
    
    func updatesWorkoutTypeIcon (workoutType: Int) {
        print("workoutType: \(workoutType)")
        if  workoutType == 0 {
            workoutTypeIcon.setImageNamed("walk")
        }
        if  workoutType == 1 {
            workoutTypeIcon.setImageNamed("run")
        }
        if  workoutType == 2 {
            workoutTypeIcon.setImageNamed("cycling")
        }
        if  workoutType == 3 {
            workoutTypeIcon.setImageNamed("paddling")
        }
    }
    
    func sectionWorkout(atIndex: Int) -> String {
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
    
    @IBAction func startButton() {
        
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        switch activationState{
        case .activated:
            print("Watch WCSEssion Activated")
        case .notActivated:
            print("Watch WCSEssion NOT Activated")
        case .inactive:
            print("Watch WCSEssion Inavtive")
        @unknown default:
            print("ERROR")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        updateLabels(message: message)
    }
    
}
