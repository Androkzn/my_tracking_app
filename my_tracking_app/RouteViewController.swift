//
//  RouteViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit
import CoreData

class RouteViewController: UIViewController {

    @IBOutlet weak var startButtonLabel: UIButton!
    
    var isTrakingStarted = false
    var locations: [Locations] = []
    var workouts: [Workout] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startButtonLabel.layer.borderWidth = 2
        startButtonLabel.layer.cornerRadius = 10
        startButtonLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    
    @IBAction func startButton(_ sender: Any) {
        
        if isTrakingStarted == false {
            isTrakingStarted = true
            startButtonLabel.backgroundColor = #colorLiteral(red: 0.9545200467, green: 0.3107312024, blue: 0.1102497205, alpha: 1)
            startButtonLabel.layer.borderColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            startButtonLabel.setTitle("STOP", for: .normal)
             
            //  save new workout
            let workout = DataManager.shared.workout(timestamp: Date(), duration: 1000, distance: 12.3, speed: 6.1, averageSpeed: 4.6, callories: 456, averageCallories: 304, bloodOxygen: 98)
            DataManager.shared.save()
            //save location
            let location1 = DataManager.shared.location(timestamp: Date(), distance: 5.2, latitude: 49.2827, longitude: 123.1207, speed: 4.5, workout: workout)
            let location2 = DataManager.shared.location(timestamp: Date(), distance: 5.3, latitude: 50.2827, longitude: 124.1207, speed: 4.6, workout: workout)
            let location3 = DataManager.shared.location(timestamp: Date(), distance: 5.4, latitude: 51.2827, longitude: 125.1207, speed: 4.7, workout: workout)
            DataManager.shared.save()
        
        
        } else {
            isTrakingStarted = false
            startButtonLabel.backgroundColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            startButtonLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
            startButtonLabel.setTitle("START", for: .normal)
            
            //fetch and print
            workouts = DataManager.shared.workout()
            locations = DataManager.shared.location()
            print(workouts)
            print(locations)
        }
 
    }
    
    


}
