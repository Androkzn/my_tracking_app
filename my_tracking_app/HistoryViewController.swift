//
//  HistoryViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-06-15.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit

class HistoryViewController: UIViewController {

    var location = Location(timestamp: Date(), longitude: 49.2827, latitude: 123.1207)
    
    var workout = WorkoutObject(timestamp: Date(), duration: 95, distance: 12.3, speed: 6.1, averageSpeed: 4.6, callories: 456, averageCallories: 304, bloodOxygen: 0, locations: [])
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }


}

extension HistoryViewController: UITableViewDataSource {


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HistoryTableViewCell
        
        cell.set()

        return cell
    }
}
