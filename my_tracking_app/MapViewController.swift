//
//  MapViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit


class MapViewController: UIViewController {

    
    @IBOutlet weak var mapLabel: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapLabel.showsUserLocation = true
    }
    


}
