//
//  ChartFormatter.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import Charts

public class ChartFormatter: NSObject, IAxisValueFormatter {
    var workoutDistance = [String] ()

    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return workoutDistance [Int(value)]
    }

    public func setValues(values: [String]) {
        self.workoutDistance = values
    }
}
