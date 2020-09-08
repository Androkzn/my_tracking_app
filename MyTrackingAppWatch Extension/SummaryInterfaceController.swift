//
//  SummaryInterfaceController.swift
//  MyTrackingAppWatch Extension
//
//  Created by Andrei Tekhtelev on 2020-09-01.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class SummaryInterfaceController: WKInterfaceController, WCSessionDelegate {

    
    @IBOutlet weak var timerLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceUnitLabel: WKInterfaceLabel!
    @IBOutlet weak var speedLabel: WKInterfaceLabel!
    @IBOutlet weak var avgSpeedLabel: WKInterfaceLabel!
    @IBOutlet weak var speedUnitLabel: WKInterfaceLabel!
    @IBOutlet weak var stepsLabel: WKInterfaceLabel!
    @IBOutlet weak var paddlesLabel: WKInterfaceLabel!
    @IBOutlet weak var caloriesLabel: WKInterfaceLabel!
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        let session = WCSession.default
           session.delegate = self
           session.activate()
    }

    override func willActivate() {
            super.willActivate()
        }

        override func didDeactivate() {
            super.didDeactivate()
        }

        func updateLabels (message: [String: Any]) {
            if let timeCurrentMessage = message ["Time"] as? String {
                     timerLabel.setText(timeCurrentMessage)
            }
            if let distanceMessage = message ["Distance"] as? String {
                     distanceLabel.setText(distanceMessage)
            }
            if let distanceUnitMessage = message ["DistanceUnit"] as? String {
                     distanceUnitLabel.setText(distanceUnitMessage)
            }
            if let speedMessage = message ["Speed"] as? String {
                     speedLabel.setText(speedMessage)
            }
            if let avgSpeedMessage = message ["AvgSpeed"] as? String {
                     avgSpeedLabel.setText(avgSpeedMessage)
            }
            if let speedUnitMessage = message ["SpeedUnit"] as? String {
                     speedUnitLabel.setText(speedUnitMessage)
            }
            if let stepsMessage = message ["Steps"] as? String {
                     stepsLabel.setText(stepsMessage)
            }
            if let caloriesMessage = message ["Calories"] as? String {
                     caloriesLabel.setText(caloriesMessage)
            }
            if let paddlesMessage = message ["Paddles"] as? String {
                     paddlesLabel.setText(paddlesMessage)
            }
            if let heartRateMessage = message ["HeartRate"] as? String {
                     heartRateLabel.setText(heartRateMessage)
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
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        updateLabels(message: message)
    }
    }
