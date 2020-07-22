//
//  ChartViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import Charts

protocol GetChartData {
    func getChartData(with dataPoints: [String], values: [String])
    var dataPoints: [String] {get set}
    var values: [String]  {get set}
}

class ChartViewController: UIViewController, GetChartData {
    var sender: Int?
    var xAxisName = ""
    var dataPoints = [String] ()
    var values = [String] ()
    
    static var currentWorkout: Workout?
    
    @IBOutlet weak var chartLabel: UILabel!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var switchLabel: UISwitch!
    @IBOutlet weak var altLabelSwitch: UILabel!
    @IBOutlet weak var speedLabelSwitch: UILabel!
    
    @IBAction func backButton(_ sender: Any) {
         dismiss(animated: true, completion: nil)
    }
    
    @IBAction func switchChartValue(_ sender: Any) {
        populateChartData()
        cubicChart()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        switchLabel.onTintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        switchLabel.backgroundColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        switchLabel.layer.cornerRadius = 15
        //populate charts data
        populateChartData()

        //LineChart
        cubicChart()

    }

    func getChartData(with dataPoints: [String], values: [String]) {
        self.dataPoints = dataPoints
        self.values = values
    }

    func populateChartData() {
        dataPoints.removeAll()
        values.removeAll()
        
        var unitxAxis = ""

        //gets unit for speed
        let unitSpeed = WorkoutDataHelper.getSpeedUnit()
        //gets unit for altitude
        let unitAltitude = WorkoutDataHelper.getAltitudeUnit()
        //get unit for distance
        let unitDistance = WorkoutDataHelper.getDistanceUnit()
        
        guard let workouts = ChartViewController.currentWorkout else {
            return
        }
        guard let locations = workouts.workoutLocations else {
            return
        }
        let  workoutLocations = WorkoutDataHelper.sortedLocations(
            locations: locations.allObjects as! [Location])
        var distance = 0.0
        var seconds = 0
        let initialTimestamp = workoutLocations.first?.timestamp ?? Date()
        print(workoutLocations)
        workoutLocations.forEach { (location) in
            distance += location.distance
            if SummaryViewController.sender == 1 {
                xAxisName = "TIME"
                let diffComponents = Calendar.current.dateComponents([.second, .minute], from: initialTimestamp, to: location.timestamp!)
                if workouts.duration < 10 {
                    let _seconds = diffComponents.second
                    if _seconds != seconds {
                        dataPoints.append(String(_seconds!))
                        unitxAxis = "sec"
                        seconds = _seconds!
                        setYAxis (location: location, unitSpeed: unitSpeed, unitxAxis: unitxAxis, unitAltitude: unitAltitude)
                    }
                }  else {
                    let _seconds = diffComponents.second
                    let _minutes = diffComponents.minute
                    if _seconds! > 0 {
                        if _seconds! < 60 && _minutes == 0 {
                            dataPoints.append(String(_seconds!))
                            unitxAxis = "sec"
                        } else {
                            dataPoints.append(String(_minutes!))
                            unitxAxis = "min"
                        }
                        setYAxis (location: location, unitSpeed: unitSpeed, unitxAxis: unitxAxis, unitAltitude: unitAltitude)
                    }
                }
            } else {
                unitxAxis = unitDistance
                xAxisName = "DISTANCE"
                print("DISTAMCE: \(workouts.distance)")
                
                if workouts.distance < 1000{
                     unitxAxis = unitAltitude
                    dataPoints.append(WorkoutDataHelper.getDisplayedAltitude(from: distance))
                } else {
                    unitxAxis = unitDistance
                    dataPoints.append(WorkoutDataHelper.getDisplayedDistance(from: distance))
                }
            
                setYAxis (location: location, unitSpeed: unitSpeed, unitxAxis: unitxAxis, unitAltitude: unitAltitude)
            }
        }
        self.getChartData(with: dataPoints, values: values)
    }
    
    func cubicChart() {
        let cubicChart = CubicChart(frame: CGRect(x: 0.0, y: 0.0,
                                                   width: self.view.frame.width * 0.9,
                                                   height: self.view.frame.height * 0.7))
        cubicChart.delegate = self
        chartView.addSubview(cubicChart)
    }
    
    func setYAxis (location: Location, unitSpeed: String, unitxAxis: String,unitAltitude: String ) {
        if switchLabel.isOn {
            let speed = location.speed
            values.append(WorkoutDataHelper.getDisplayedSpeed(from: speed >= 0 ? speed : 0.0))
            altLabelSwitch.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            speedLabelSwitch.textColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            chartLabel.text = "SPEED(\(unitSpeed)) — \(xAxisName)(\(unitxAxis))"
        } else {
            values.append(WorkoutDataHelper.getDisplayedAltitude(from: location.altitude))
            altLabelSwitch.textColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            speedLabelSwitch.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            chartLabel.text = "ALTITUDE(\(unitAltitude)) — \(xAxisName)(\(unitxAxis))"
        }
    }
    
}
