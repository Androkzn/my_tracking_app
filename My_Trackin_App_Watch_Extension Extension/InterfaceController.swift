//
//  InterfaceController.swift
//  My_Trackin_App_Watch_Extension Extension
//
//  Created by Andrei Tekhtelev on 2020-08-26.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var workoutTypeIcon: WKInterfaceImage!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var startButtonLabel: WKInterfaceButton!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateLabels ()
        updatesWorkoutTypeIcon ()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateLabels () {
        let userDefaults = UserDefaults(suiteName: "group.my_tracking_app")
        userDefaults!.synchronize()
        let workoutType = userDefaults!.integer(forKey: "WORKOUT")
        startButtonLabel.setTitle("\(sectionWorkout(atIndex: workoutType))")
        
    }
    
    func updatesWorkoutTypeIcon () {
        let userDefaults = UserDefaults(suiteName: "group.my_tracking_app")
        let workoutType = userDefaults!.integer(forKey: "WORKOUT")
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
    
}
