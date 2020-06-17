//
//  DataManager.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-16.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import CoreData

class DataManager {
    
    static let shared  = DataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "my_tracking_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

  
    func workout (timestamp: Date, duration: Int16, distance: Double, speed: Double, averageSpeed: Double, callories: Int16, averageCallories: Int16, bloodOxygen: Int16) -> Workout {
        let workout = Workout(context: persistentContainer.viewContext)
        workout.timestamp = timestamp
        workout.duration = duration
        workout.speed = speed
        workout.averageSpeed = averageSpeed
        workout.callories = callories
        workout.averageCallories = averageCallories
        workout.bloodOxygen = bloodOxygen
        return workout
    }
    
    func location (timestamp: Date, distance: Double, latitude: Double, longitude: Double, speed: Double, workout: Workout) -> Locations {
        let location = Locations(context: persistentContainer.viewContext)
        location.timestamp = timestamp
        location.distance = distance
        location.latitude = latitude
        location.longitude = longitude
        location.speed = speed
        location.workout = workout
        return location
    }
    
    
    func workout() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        var fetcedWorkouts: [Workout] = []
        do {
            fetcedWorkouts = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error")
        }
        return fetcedWorkouts
    }
    
    func location() -> [Locations] {
        let request: NSFetchRequest<Locations> = Locations.fetchRequest()
        
        var fetcedLocations: [Locations] = []
        do {
            fetcedLocations = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error")
        }
        return fetcedLocations
    }

    

    func save () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
