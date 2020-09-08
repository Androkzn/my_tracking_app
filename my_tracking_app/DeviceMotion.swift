//
//  Pedometer.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-08-14.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import CoreMotion

class DeviceMotion {
    
    var steps: Int16 = 0
    var distance: Double = 0
    
    static let shared  = DeviceMotion()
    let pedometer = CMPedometer()

    //updates pedometer data
    func getSteps (seconds: Int16) {
        if CMPedometer.isStepCountingAvailable() {
        let startDate = Calendar.current.date(byAdding: .second, value: -Int(seconds), to: Date())
        pedometer.queryPedometerData(from: startDate!, to: Date()) { (data, error) in
                //print("Pedometer data: \(data!)")
                self.distance = Double(truncating: (data?.distance)!)
                self.steps =  Int16(truncating: (data?.numberOfSteps)!)
                
            }
        }
    }
    
    //updates pedometer data each time there is an update to your step count or any other pedometer data
    func getStepsUpdate (seconds: Int16) {
        if CMPedometer.isStepCountingAvailable() {
            let startDate = Calendar.current.date(byAdding: .second, value: -Int(seconds), to: Date())
            pedometer.startUpdates(from: startDate!) { (data, error) in
         
                self.distance = Double(truncating: (data?.distance)!)
                //print(self.distance)
                self.steps =  Int16(truncating: (data?.numberOfSteps)!)
                //print(self.steps)
                
            }
        }
    }
    
}
