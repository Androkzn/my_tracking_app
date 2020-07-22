//
//  MapViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import UIKit

class GlobalTimer {

    static let shared  = GlobalTimer()
    var timer = Timer()
    var seconds: Int16 = 0

    func startTimer(_ vc: MapViewController) {
        seconds = 0
        timer = Timer.scheduledTimer(timeInterval: 1,
                target: vc,
                selector: #selector(vc.eachSecond(timer:)),
                userInfo: nil,
                repeats: true)
    }
    
    func stopTimer() {
        timer.invalidate()
    }
    
    //date formatter from seconds to Hours: Min
    func secondsFormatter (seconds : Int16) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
    
    func secondsFormatterToSpokenDuration(seconds: Int16) -> String {
        let hours = seconds / 3600
        let minutes = seconds / 60 % 60
        let seconds = seconds % 60
        
        let hourString = hours > 0 ? "\(hours) hours, " : ""
        let minuteString = minutes > 0 ? "\(minutes) minutes and" : ""
        let secondString = seconds > 0 ? "\(seconds) seconds " : ""
        
        return "\(hourString) \(minuteString) \(secondString)"
    }
    
    func getTime() -> String {
        return String(secondsFormatter(seconds: seconds))
    }
}
