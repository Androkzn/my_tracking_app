//
//  HistoryViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit


class HistoryViewController: UIViewController {
    var locations: [Locations] = []
    var workouts: [Workout] = []
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
      override func viewWillAppear(_ animated: Bool) {
         super.viewWillAppear(true)
         workouts = DataManager.shared.workout()
         print(workouts.count)
         tableView.reloadData()

     }
    
     override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }

}

extension HistoryViewController: UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
 
        let workout = workouts[indexPath.row]
        if let allLocations = workouts[indexPath.row].workoutLocations?.allObjects as? [Locations] {
            locations = allLocations
        }
        
        if locations.count == 0 {
        cell.set(timestamp: workout.timestamp!, time: workout.duration, distance: workout.distance, averageSpeed: workout.averageSpeed, callories: workout.callories, latitude: 0, longitude: 0)
        } else {
        cell.set(timestamp: workout.timestamp!, time: workout.duration, distance: workout.distance, averageSpeed: workout.averageSpeed, callories: workout.callories, latitude: locations[0].latitude, longitude: locations[0].longitude)
        }

        return cell
    }
}
