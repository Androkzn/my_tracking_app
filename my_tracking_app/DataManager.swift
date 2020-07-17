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
        let container = NSPersistentContainer(name: "my_tracking_app")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
  
    func workout(timestamp: Date) -> Workout {
        let workout = Workout(context: persistentContainer.viewContext)
        workout.timestamp = timestamp
        return workout
    }
    
    func location(timestamp: Date, distance: Double, latitude: Double, longitude: Double, speed: Double, altitude: Double, workout: Workout) -> Location {
        let location = Location(context: persistentContainer.viewContext)
        location.timestamp = timestamp
        location.distance = distance
        location.latitude = latitude
        location.longitude = longitude
        location.speed = speed
        location.altitude = altitude
        location.workout = workout
        return location
    }
    
    // Fetches workouts in chronological order
    func workouts() -> [Workout] {
        let request: NSFetchRequest<Workout> = Workout.fetchRequest()
        request.includesPendingChanges = false
        let sort = NSSortDescriptor(key: #keyPath(Workout.timestamp), ascending: false)
        request.sortDescriptors = [sort]
        
        var fetchedWorkouts: [Workout] = []
        do {
            fetchedWorkouts = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error")
        }
        return fetchedWorkouts
    }
    
    // Fetches locations in chronological order
    // Probably redundant method because we have acces to locations through workout
    func locations() -> [Location] {
        let request: NSFetchRequest<Location> = Location.fetchRequest()
        request.includesPendingChanges = false
        let sort = NSSortDescriptor(key: #keyPath(Location.timestamp), ascending: true)
        request.sortDescriptors = [sort]

        var fetchedLocations: [Location] = []
        do {
            fetchedLocations = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error")
        }
        return fetchedLocations
    }

    //saves data in DB
    func save() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func resetAllRecords(in entity : String) {
        let context = DataManager.shared.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
}
