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
    
    static let shared  = InterfaceController()
    
    var workoutType = WorkoutShared.shared.workoutType
    var isTrackingStarted = false
    var isIOSAppOpened = WorkoutShared.shared.isIOSAppOpened
    var isProfileFilledOut = WorkoutShared.shared.isProfileFilledOut
    var timeCurrent = "00:00:00"
    var distance = 0.0
    var distanceUnit = ""
    var speed = 0.0
    var avgSpeed = 0.0
    var speedUnit = ""
    var steps = 0
    var calories = 0
    var paddles = 0
    var heartRate = 0
    var isWorkoutStarted = false
    var isPared = false
    let session = WCSession.default
    
    @IBOutlet weak var workoutTypeIcon: WKInterfaceImage!
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var startButtonLabel: WKInterfaceButton!
    @IBOutlet weak var workoutTabGestureRecognizer: WKTapGestureRecognizer!
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        //session = WCSession.default
        session.delegate = self
        session.activate()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        let session = WCSession.default
        session.delegate = self
        session.activate()
        if !isTrackingStarted {
            updateLabelsAfterStop ()
        }
        setUpInitialButtonState(isOpened: WorkoutShared.shared.isIOSAppOpened, isProfileFilledOut: WorkoutShared.shared.isProfileFilledOut)
    }
    
    override func  didAppear() {
        super.didAppear()
        let seconds = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            self.setUpInitialRecognizerState (isOpened: WorkoutShared.shared.isIOSAppOpened)
        }
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func leftSwipe(_ sender: Any) {
       presentController(withName: "summary", context: nil)
    }
    
    func updateLabels (message: [String: Any]) {
        if  let workoutTypeMessage = message ["WorkoutType"] as? Int {
            workoutType = workoutTypeMessage
            WorkoutShared.shared.workoutType = workoutTypeMessage
        }
        
        if  let isIOSAppOpenedMessage = message ["iOSOpened"] as? Bool {
            WorkoutShared.shared.isIOSAppOpened = isIOSAppOpenedMessage
            setUpInitialButtonState(isOpened: WorkoutShared.shared.isIOSAppOpened, isProfileFilledOut: WorkoutShared.shared.isProfileFilledOut)
            setUpInitialRecognizerState (isOpened: WorkoutShared.shared.isIOSAppOpened)

        }
        
        if  let isProfileFilledOutMessage = message ["isProfileFilledOut"] as? Bool {
            WorkoutShared.shared.isProfileFilledOut = isProfileFilledOutMessage
        }
        
        if let isTrackingStartedMessage = message ["isTrackingStarted"] as? Bool {
            isTrackingStarted = isTrackingStartedMessage
            isWorkoutStarted = isTrackingStartedMessage
        }
        
        if let timeCurrentMessage = message ["Time"] as? String {
            if isTrackingStarted {
                timeCurrent = timeCurrentMessage
            } else {
                timeCurrent = "00:00:00"
            }
        }
 
        updatesWorkoutTypeIcon(workoutType: workoutType)
        timerLabel.setText(timeCurrent)
        
        if isTrackingStarted {
            startButtonLabel.setTitle("STOP")
            startButtonLabel.setBackgroundColor(#colorLiteral(red: 0.9545200467, green: 0.3107312024, blue: 0.1102497205, alpha: 1))
         } else {
            startButtonLabel.setTitle(sectionWorkout(atIndex: workoutType))
            startButtonLabel.setBackgroundColor(#colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1))
         }
    }
    
    func setUpInitialButtonState(isOpened: Bool, isProfileFilledOut: Bool) {
        if isOpened {
            startButtonLabel.setEnabled(true)
            startButtonLabel.setTitle(sectionWorkout(atIndex: WorkoutShared.shared.workoutType))
        } else {
            startButtonLabel.setTitle("Open iOS App first")
            startButtonLabel.setEnabled(false)
        }
    }
    
    func checkProfileSetUp (isProfileFilledOut: Bool) -> Bool {
        var setUp = false
        if isProfileFilledOut {
            startButtonLabel.setTitle(sectionWorkout(atIndex: WorkoutShared.shared.workoutType))
            setUp = true
        } else {
            startButtonLabel.setTitle("Fill out Profile")
        }
        return setUp
    }
    
    
    func checkHealthPermission (isGranted: Bool) -> Bool {
        var granted = false
        if isGranted{
            startButtonLabel.setTitle(sectionWorkout(atIndex: WorkoutShared.shared.workoutType))
            granted = true
        } else {
            startButtonLabel.setTitle("Get permissions first")
        }
        return granted
    }
    
    func setUpInitialRecognizerState(isOpened: Bool) {
         if isOpened {
             workoutTabGestureRecognizer.isEnabled = true
         } else {
             workoutTabGestureRecognizer.isEnabled = false
         }
     }
    
    
    func updateLabelsAfterStop () {
        updatesWorkoutTypeIcon(workoutType: workoutType)
        timerLabel.setText("00:00:00")
        startButtonLabel.setTitle(sectionWorkout(atIndex: workoutType))
        startButtonLabel.setBackgroundColor(#colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1))
    }
    
    func updatesWorkoutTypeIcon (workoutType: Int) {
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

        if isTrackingStarted {
            startButtonLabel.setEnabled(false)
            self.presentController(withName: "summary", context: nil)
            isTrackingStarted = false
        }
        
        _ = checkProfileSetUp(isProfileFilledOut: WorkoutShared.shared.isProfileFilledOut)
        
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["PressStart" : true], replyHandler: { (reply) in
                if let didPress = reply["PressStart"] as? Bool {
                    if didPress {
                        if self.isWorkoutStarted {
                            self.startButtonLabel.setEnabled(true)
                            self.isWorkoutStarted = false
                        }
                    }
                }
            }) { (error) in
                print("Messaging Error: \(error.localizedDescription)")
            }
        }
//        self.isWorkoutStarted = false
//        presentController(withName: "summary", context: nil)
//        self.startButtonLabel.setEnabled(true)
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
        DispatchQueue.main.async {
            self.updateLabels(message: message)
        }
    }
    
    @IBAction func tapWorkoutIcon(_ sender: Any) {
        self.presentController(withName: "workoutType", context: nil)
    }
    
    
}
