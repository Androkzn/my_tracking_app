//
//  HealthData.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-08-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import HealthKit

class HealthData {
    
    static let shared  = HealthData()
    var healthStore = HKHealthStore()
    
 
    
    func requestAutorization () {
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        
        healthStore.requestAuthorization(toShare: [], read: [stepType]) { (success, error) in
            if (success) {
                print("Permission granted")
            }
        }
        
    }
    
}
