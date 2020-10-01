//
//  HistoryTableViewCell.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit

class HistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var snapshot: UIImageView!
    @IBOutlet weak var workoutTypeLabel: UILabel!
    
    // Set up cell with image and labels
    func set(image: UIImage, timestamp: Date, time: Int16, distance: Double,
             averageSpeed: Double, workout: Int16) {
        snapshot.image = image
        timestampLabel.text = WorkoutDataHelper.dateFormatter(date: timestamp)
        timeLabel.text = GlobalTimer.shared.secondsFormatter(seconds: time)
        distanceLabel.text = WorkoutDataHelper.getCompleteDisplayedDistance(from: distance)
        averageSpeedLabel.text = WorkoutDataHelper.getCompleteDisplayedSpeed(from: averageSpeed)
        workoutTypeLabel.text = WorkoutDataHelper.getDisplayWorkoutType(from: Int(workout))
        
    }
}
