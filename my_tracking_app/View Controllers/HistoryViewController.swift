//
//  HistoryViewController.swift
//  my_tracking_app
 //
 //  Created by Andrei Tekhtelev on 2020-07-13.
 //  Copyright © 2020 HomeFoxDev. All rights reserved.
 //

import UIKit

class HistoryViewController: UIViewController {
    var locations: [Location] = []
    var workouts: [Workout] = []
    var selectedWorkout: Workout?
    var convertedImage: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var emptyTableLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        emptyTableLabel.text = "Let's go out and have some fun!"
    }
    
    //reloads the History table
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //refresh workouts every time when the view will appear
        workouts = DataManager.shared.workouts()
        self.tableView.tableFooterView = UIView()
        emptyTableLabel.isHidden = !workouts.isEmpty
        SummaryViewController.isSaved = false
     }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //reloads the TableView
        tableView.reloadData()
    }
    
    @IBSegueAction func summary(_ coder: NSCoder) -> UIViewController? {
        let summaryVC = SummaryViewController(coder: coder)
        let selectedWorkout = tableView.indexPathForSelectedRow!.row
        summaryVC?.currentWorkout = workouts[selectedWorkout]
        ChartViewController.currentWorkout = workouts[selectedWorkout]
        summaryVC?.savingSnapshot = false
        return summaryVC
    }
}

extension HistoryViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
}

extension HistoryViewController: UITableViewDataSource {

    //sets up number of table's cells based on number of workouts
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workouts.count
    }
    
    //sets up each cell based on data for each workout
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
 
        let workout = workouts[indexPath.row]
        if let allLocations = workouts[indexPath.row].workoutLocations?.allObjects as? [Location] {
            locations = allLocations
        }
        
        convertedImage = UIImage()
        if let data = workout.image {
            convertedImage = UIImage(data: data)!
        }
        
        cell.set(image: convertedImage!, timestamp: workout.timestamp!,
                 time: workout.duration, distance: workout.distance,
                 averageSpeed: workout.averageSpeed, workout: workout.type)

        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let workout = workouts[indexPath.row]
            DataManager.shared.persistentContainer.viewContext.delete(workout)
            
            workouts.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            DataManager.shared.save()
        }
    }
}

