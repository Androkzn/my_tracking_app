//
//  HistoryTableViewCell.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit

class HistoryTableViewCell: UITableViewCell {

    
    
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var miniMapLabel: MKMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var calloriesLabel: UILabel!
    
    
    
    func set (timestamp: Date, time: Int16, distance: Double, averageSpeed: Double, callories: Int16, latitude: Double, longitude: Double) {
        timestampLabel.text = dateFormater(date: timestamp)
        timeLabel.text = secondsFormatter(seconds: time)
        distanceLabel.text = String(distance)
        averageSpeedLabel.text = String(averageSpeed)
        calloriesLabel.text = String(callories)
    }
    
    func dateFormater(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm E, d MMM y"
        return formatter.string(from: date)
    }
    
    func secondsFormatter (seconds : Int16) -> String {
        let timestampString = "\(seconds / 3600):\((seconds % 3600) / 60):\((seconds % 3600) % 60)"
        return timestampString
    }
}

