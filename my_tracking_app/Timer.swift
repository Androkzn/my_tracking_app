//
//  MapViewController.swift
//  my_tracking_app
//
//  Final project comp-3912-spring-2020
//  Created by Team #1
//  Olivia Hourcade
//  Sebastian Bejm
//  Andrei Tekhtelev
//  2020-06-15.
//  Copyright © 2020. All rights reserved.
//

import Foundation
import UIKit

class GlobalTimer {

    static let shared  = GlobalTimer()
    var timer = Timer()
    var seconds:Int16 = 0

    func startTimer (_ vc: MapViewController) {
        seconds = 0
        print("Start Timer")
        timer = Timer.scheduledTimer(timeInterval: 1,
                target: vc,
                selector: #selector(vc.eachSecond(timer:)),
                userInfo: nil,
                repeats: true)
    }
    
    func stopTimer() {
        print("Stop Timer")
        timer.invalidate()
    }
    
    //date formatter from seconds to Hours: Min
    func secondsFormatter (seconds : Int16) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func getTime() -> String{
        return String(secondsFormatter(seconds: seconds))
    }
    
    
}
    
