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
    var steps: Int16 = 0
    var totalSteps: Int16 = 0
    var heartRate: Int16 = 0
    var caloriesBurned: Int16 = 0
    var totalCaloriesBurned: Int16 = 0
    var isHealthPermissionGranted = false

    func requestAutorization () {
        let stepType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount)!
        let heartType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let energyType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned)!

        healthStore.requestAuthorization(toShare: [], read: [stepType, heartType, energyType]) { (success, error) in
            if (success) {
                print("Permission granted")
                self.isHealthPermissionGranted = true
            }
        }
    }

    func latestSteps (seconds: Int16) {
        steps = 0
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.stepCount) else {
            return
        }

        let startDate = Calendar.current.date(byAdding: .second, value: -Int(seconds), to: Date())

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

        let  sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let querry = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else {
                return
            }

           result!.forEach { (eachResult) in
                let data = eachResult as! HKQuantitySample
                let unit = HKUnit(from: "count")
                let latestSteps = data.quantity.doubleValue(for: unit)
                self.steps += Int16(latestSteps)

            }
//            print("Duration: \(seconds)")
//            print("Total steps: \(self.steps)")
            self.totalSteps = self.steps
        }
        healthStore.execute(querry)
    }

    func latestHeartRate (seconds: Int16) {
            guard let sampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                return
            }

            let startDate = Calendar.current.date(byAdding: .second, value: -Int(seconds), to: Date())

            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

            let  sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

            let querry = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
                guard error == nil else {
                    return
                }

                if result!.count > 0  {
                    let data =  result![0] as! HKQuantitySample
                    let unit = HKUnit(from: "count/min")
                    let latestRate = data.quantity.doubleValue(for: unit)
                    self.heartRate = Int16(latestRate)
                    //print("Heart Rate: \(latestRate)")
                } else {
                    //print("Heart rate is not avaliable")
                }

            }
            healthStore.execute(querry)
        }

    func latestEnergyBurned (seconds: Int16) {
        caloriesBurned = 0
        guard let sampleType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
            return
        }

        let startDate = Calendar.current.date(byAdding: .second, value: -Int(seconds), to: Date())

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: .strictEndDate)

        let  sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)

        let querry = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: Int(HKObjectQueryNoLimit), sortDescriptors: [sortDescriptor]) { (sample, result, error) in
            guard error == nil else {
                return
            }

            result!.forEach { (eachResult) in
                let data =  result![0] as! HKQuantitySample
                let unit = HKUnit(from: "kcal")
                let latestCalories = data.quantity.doubleValue(for: unit)
                self.caloriesBurned = Int16(latestCalories)
                //print("Callories: \(latestCalories)")
            }
            self.totalCaloriesBurned = self.caloriesBurned
        }
        healthStore.execute(querry)
    }

}
