//
//  WorkoutType.swift
//  MyTrackingAppWatch Extension
//
//  Created by Andrei Tekhtelev on 2020-09-17.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class WorkoutType: WKInterfaceController, WCSessionDelegate {
    
    
    
    let checkedCheckbox = UIImage(systemName: "checkmark.square.fill")
    let uncheckedCheckbox = UIImage(systemName: "square")
    
    @IBOutlet weak var walkGroup: WKInterfaceGroup!
    @IBOutlet weak var runGroup: WKInterfaceGroup!
    @IBOutlet weak var bikeGroup: WKInterfaceGroup!
    @IBOutlet weak var paddleGroup: WKInterfaceGroup!
    
    @IBOutlet weak var walkCheckbox: WKInterfaceImage!
    @IBOutlet weak var runCheckbox: WKInterfaceImage!
    @IBOutlet weak var bikeCheckbox: WKInterfaceImage!
    @IBOutlet weak var paddleCheckbox: WKInterfaceImage!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let session = WCSession.default
        session.delegate = self
    }

    override func willActivate() {
        super.willActivate()
        sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    
    @IBAction func walkTap(_ sender: Any) {
        WorkoutShared.shared.workoutType = 0
        sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
        sendWorkoutType ()
        dismiss()
    }

    @IBAction func runTap(_ sender: Any) {
        WorkoutShared.shared.workoutType = 1
        sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
        sendWorkoutType ()
        dismiss()
    }
    
    @IBAction func bikeTap(_ sender: Any) {
        WorkoutShared.shared.workoutType = 2
        sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
        sendWorkoutType ()
        dismiss()
    }
    
    @IBAction func paddleTap(_ sender: Any) {
        WorkoutShared.shared.workoutType = 3
        sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
        sendWorkoutType ()
        dismiss()
    }
    
    func sectionWorkout(atIndex: Int) {
        if atIndex == 0 {
            walkCheckbox.setImage(checkedCheckbox)
            runCheckbox.setImage(uncheckedCheckbox)
            bikeCheckbox.setImage(uncheckedCheckbox)
            paddleCheckbox.setImage(uncheckedCheckbox)
        }
        if atIndex == 1 {
            walkCheckbox.setImage(uncheckedCheckbox)
            runCheckbox.setImage(checkedCheckbox)
            bikeCheckbox.setImage(uncheckedCheckbox)
            paddleCheckbox.setImage(uncheckedCheckbox)
        }
        if atIndex == 2 {
            walkCheckbox.setImage(uncheckedCheckbox)
            runCheckbox.setImage(uncheckedCheckbox)
            bikeCheckbox.setImage(checkedCheckbox)
            paddleCheckbox.setImage(uncheckedCheckbox)
        }
        if atIndex == 3 {
            walkCheckbox.setImage(uncheckedCheckbox)
            runCheckbox.setImage(uncheckedCheckbox)
            bikeCheckbox.setImage(uncheckedCheckbox)
            paddleCheckbox.setImage(checkedCheckbox)
        }
        
        
    }
    
    func updatesWorkoutTypeIcon (message: [String: Any]) {
         
        if  let workoutTypeMessage = message ["WorkoutType"] as? Int {
            WorkoutShared.shared.workoutType = workoutTypeMessage
            sectionWorkout(atIndex: WorkoutShared.shared.workoutType)
        }
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
    
    func sendWorkoutType () {
        if WCSession.default.isReachable {
                   WCSession.default.sendMessage(["WorkoutType": WorkoutShared.shared.workoutType], replyHandler: { (reply) in
                       if let didPress = reply["WorkoutType"] as? Bool {
                           if didPress {}
                           }
        }) { (error) in
                       print("Messaging Error: \(error.localizedDescription)")
                   }
               }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        updatesWorkoutTypeIcon(message: message)
    }
}
