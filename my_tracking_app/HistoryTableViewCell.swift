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
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var calloriesLabel: UILabel!
    
    
    
    func set () {
//        timestampLabel.text =  timestamp
 //         miniMapLabel.showsUserLocation = true
//        distanceLabel.text = "12.3 km"
//        averageSpeedLabel.text = "4.6 km/h"
//        calloriesLabel.text = "456 kcal"
 }
    
}
