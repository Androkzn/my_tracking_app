//
//  MotionManager.swift
//  MyTrackingAppWatch Extension
//
//  Created by Andrei Tekhtelev on 2020-09-08.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import CoreMotion
import WatchKit

protocol MotionManagerDelegate: class {
    func didUpdateMotion(_ manager: MotionManager, gravityStr: String, rotationRateStr: String, userAccelStr: String, attitudeStr: String)
}

extension Date {
    var millisecondsSince1970:Int64 {
        return Int64((self.timeIntervalSince1970 * 1000.0).rounded())
    }
}

class MotionManager {

    let motionManager = CMMotionManager()
    let queue = OperationQueue()
    let wristLocationIsLeft = WKInterfaceDevice.current().wristLocation == .left


}
