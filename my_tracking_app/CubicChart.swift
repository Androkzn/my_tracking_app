//
//  CubicChart.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import Charts

class CubicChart: UIView {
    
    //Cubic line graph properties
    let lineChartView = LineChartView()
    var lineDataEntry: [ChartDataEntry] = []
    
    //Chart data
    var dataPoints = [String]()
    var values = [String]()
    
    var delegate: GetChartData! {
        didSet{
            populateData()
            cubicLineChartSetup()
        }
    }
    
    func populateData() {
        dataPoints = delegate.dataPoints
        values = delegate.values
    }
    
    func cubicLineChartSetup() {
        //line chart config
        self.backgroundColor = #colorLiteral(red: 0.8047671914, green: 0.9335482717, blue: 1, alpha: 1)
        self.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: self.topAnchor,
                                           constant: 20).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor,
                                              constant: 20).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor,
                                               constant: 20).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor,
                                                constant: 20).isActive = true
        
        //line chart animation
        lineChartView.animate(xAxisDuration: 1.0, yAxisDuration: 1.0, easingOption: .easeInSine)
        lineChartView.notifyDataSetChanged()
        //line chart population
        setCubicLineChart(dataPoints: dataPoints, values: values)
    }
    
    func setCubicLineChart (dataPoints: [String], values: [String]) {
        //No data setup
        lineChartView.noDataTextColor = UIColor.white
        lineChartView.noDataText = "No data for the chart"
        lineChartView.backgroundColor = #colorLiteral(red: 0.8047671914, green: 0.9335482717, blue: 1, alpha: 1)

        //data point setup and color config
        for i in 0..<dataPoints.count {
            let dataPoint = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineDataEntry.append(dataPoint)
        }
        //let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: "")
        var legend = ""
        if SummaryViewController.sender == 1 {
            legend = "TIME"
        } else {
            legend = "DISTANCE"
        }
        let chartDataSet = LineChartDataSet(entries: lineDataEntry, label: legend)
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(false) //values above bars
        chartDataSet.colors = [UIColor.orange]
        chartDataSet.setCircleColor(UIColor.orange)
        chartDataSet.circleHoleColor = UIColor.orange
        chartDataSet.circleRadius = 4.0
        chartDataSet.mode = .cubicBezier
        chartDataSet.cubicIntensity = 0.2
        chartDataSet.drawCirclesEnabled = false
        chartDataSet.valueFont = UIFont(name: "Helvetica", size: 12.0)!
        
        //gradient fill
        let gradientColours = [UIColor.orange.cgColor, UIColor.clear.cgColor] as CFArray
        // Positioning of gradient
        let colorLocations: [CGFloat] = [1.0, 0.0]
        guard let gradient = CGGradient.init (colorsSpace: CGColorSpaceCreateDeviceRGB(),
                                              colors: gradientColours,
                                              locations: colorLocations) else {
            return
        }
        chartDataSet.fill = Fill.fillWithLinearGradient(gradient, angle: 90)
        chartDataSet.drawFilledEnabled = true
        
        //Axes setup
        let formatter: ChartFormatter = ChartFormatter()
        formatter.setValues(values: dataPoints)
        let xasis: XAxis = XAxis()
        xasis.valueFormatter = formatter
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = false
        lineChartView.xAxis.valueFormatter = xasis.valueFormatter
        lineChartView.chartDescription?.enabled = true
        lineChartView.legend.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.leftAxis.drawGridLinesEnabled = true
        lineChartView.leftAxis.drawLabelsEnabled = true
        lineChartView.data = chartData
    }
}
