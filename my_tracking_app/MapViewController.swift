//
//  MapViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreLocation
import HealthKit
import MapKit
import CoreData
import RSSelectionMenu

class MapViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //Outlets
    @IBOutlet weak var recenterButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var startButtonLabel: UIButton!
    @IBOutlet weak var mapLabel: MKMapView!

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timeUnitLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!

    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedUnitLabel: UILabel!

    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedUnitLabel: UILabel!

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var counterTextLabel: UILabel!
    @IBOutlet weak var progressBarLabel: UIProgressView!
    @IBOutlet weak var iconAltitudeLabel: UIImageView!
    @IBOutlet weak var altitudeLabel: UILabel!
    
    @IBOutlet weak var firstCardLabel: UIView!
    @IBOutlet weak var secondCardLabel: UIView!
    @IBOutlet weak var thirdCardLabel: UIView!
    @IBOutlet weak var fourthCardLabel: UIView!
    
    //Variables
    var isTrackingStarted = false
    var currentLocations: [Location] = [] // Current workout locations
    var currentWorkout: Workout? // Reset only when we're back from SummaryViewController
    var currentWorkoutDistance = 0.0 // Raw distance in meters
    var currentWorkoutSpeedSum = 0.0 // Addition of raw speeds in meter per second
    var counter = 2.0 //stop button timer counter
    var lastLocation: CLLocation?
    var locationManager: CLLocationManager!
    var overlays: [MKPolyline] = [] // From MapViewDelegate protocol, workout route
    var nextMilestone: Double = 0.0 // The closest milestone after reaching E.g. 1 mile, 2 miles, etc.
    var milestone: Double = 0.0 //Milstone from settings
    var editedCard: Int? //Stores value of edited card tag
    var selectedName: [String] = [] //selected cars name after editing
    var selectedNames: [String] = ["TIME", "DISTANCE", "SPEED", "AVG SPEED"] //selected cars names

    override func viewDidLoad() {
        super.viewDidLoad()

        //Tap function will call when user tap on button
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector (startButton))
        //Long press function will call when user long presses on button.
        let longGesture = UILongPressGestureRecognizer(target: self,
                                                       action: #selector(stopButton))
        tapGesture.numberOfTapsRequired = 1
        button.addGestureRecognizer(tapGesture)
        button.addGestureRecognizer(longGesture)
        longGesture.minimumPressDuration = 0.5
        setMilestones()
        setupCenterButton()
        setupSettingsButton()
        setupLocationManager()
        setupWorkoutButton(started: isTrackingStarted)
        setupMapView()
        resetLabels()
        setupContainersTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setMilestones()
        setMapType()
        centerToCurrentLocation()
        refreshUnitLabels()
        showSavedWorkoutToast()
        setUpAltitudeLaberl ()
    }
    
    //shows toast if workout just saved
    func showSavedWorkoutToast () {
        if SummaryViewController.isSaved {
            ToastView.shared.blueToast(view,
                                       txt_msg: "Your workout has been saved successfully",
                                       duration: 4)
            SummaryViewController.isSaved = !SummaryViewController.isSaved
        }
    }
    
    //set up altitude label and icon depends on map type
    func setUpAltitudeLaberl () {
        if  mapLabel.mapType == .standard {
            altitudeLabel.textColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            iconAltitudeLabel.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        } else {
            altitudeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            iconAltitudeLabel.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    func conectLabelandCoreData (label: String, speed: CLLocationSpeed)  -> String {
        var data: String = ""
        if label == "TIME" {
            data = GlobalTimer.shared.getTime()
        }
        if label == "DISTANCE" {
            data = WorkoutDataHelper.getDisplayedDistance(from: currentWorkoutDistance)
        }
        if label == "SPEED" {
            print("speed")
            data = WorkoutDataHelper.getDisplayedSpeed(from: speed)
        }
        if label == "AVG SPEED" {
             data = WorkoutDataHelper.getDisplayedSpeed(from: averageSpeed())
        }
        if label == "HEART RATE" {
            
        }
        if label == "CALLORIES" {
            
        }
        print(data)
        return data
    }

    // Set the destination view controller's workout property before showing
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SummaryViewController {
            if let currentWorkout = currentWorkout {
                destination.currentWorkout = currentWorkout
                destination.savingSnapshot = true
            }
        } else if let destination = segue.destination as? SettingsViewController {
           destination.modalPresentationStyle = .fullScreen
       }
    }

    @IBAction func centerMap(_ sender: UIButton) {
        centerToCurrentLocation()
    }

    @objc func startButton(_ sender: UITapGestureRecognizer) {
        // Start new workout button pressed
        if lastLocation != nil {
            if !isTrackingStarted {
                isTrackingStarted = !isTrackingStarted
                setupWorkoutButton(started: isTrackingStarted)
                startWorkout()
            } else {
                ToastView.shared.redToast(view, txt_msg: "Long Press STOP button for 3 seconds to stop workout", duration: 3)
            }
        } else {
            ToastView.shared.redToast(view,
            txt_msg: "Your location service is not available, please enable Location on your device",
            duration: 2)
        }
    }
    
    @objc func stopButton(_ sender: UILongPressGestureRecognizer) {
        if isTrackingStarted {
            if sender.state == .began {
                _ = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
                    if self.counter >= 0 {
                        if sender.state == .possible {
                            timer.invalidate()
                            self.setupCounterLabel(started: false)
                            return
                        } else {
                            self.setupCounterLabel(started: true)
                        }
                    } else {
                        timer.invalidate()
                        self.setupCounterLabel(started: false)
                        if self.isTrackingStarted {
                            self.isTrackingStarted = !self.isTrackingStarted
                            self.setupWorkoutButton(started: self.isTrackingStarted)
                            self.stopWorkout()
                            self.performSegue(withIdentifier: "summaryView", sender: nil)
                        }
                    }
                    self.counter = (self.counter - 0.01)
                }
            }
        }
    }
    
    func setupCounterLabel (started: Bool) {
        counterTextLabel.layer.backgroundColor = #colorLiteral(red: 0.3249011148, green: 0.7254286438, blue: 0.9069467254, alpha: 0.8043396832)
        counterTextLabel.layer.cornerRadius = 10
        counterTextLabel.layer.borderWidth = 1.0
        counterTextLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        if started {
            startButtonLabel.titleLabel?.textColor = #colorLiteral(red: 0.9596351981, green: 0.4475290775, blue: 0.2867116332, alpha: 1)
            ToastView.shared.stopAnimation()
            counterTextLabel.layer.isHidden = false
            progressBarLabel.isHidden = false
            counterTextLabel.text = "Keep pressing STOP button \n\(Int(self.counter)) sec"
            progressBarLabel.progress = Float(self.counter/3)
        } else {
            startButtonLabel.titleLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            counterTextLabel.layer.isHidden = true
            progressBarLabel.isHidden = true
            self.counterTextLabel.text = ""
            self.counter = 3
        }
    }
    
    //updates labels each second
    @objc func eachSecond(timer: Timer) {
        GlobalTimer.shared.seconds += 1
        var speedMPS: CLLocationSpeed = 0

        if let lastLocation = lastLocation {
            // Update speed labels
            speedMPS = lastLocation.speed >= 0.0 ? lastLocation.speed : 0.0
            speedLabel.text = conectLabelandCoreData(label: selectedNames[2], speed: speedMPS)
            speedUnitLabel.text = selectedNames[2]
            averageSpeedLabel.text = conectLabelandCoreData(label: selectedNames[3], speed: speedMPS)
            averageSpeedUnitLabel.text = selectedNames[3]
            //Update altitude label
            altitudeLabel.text = WorkoutDataHelper.getCompleteDisplayedAltitude(from: lastLocation.altitude)
            
            // Update timer label
            //timeLabel.text = GlobalTimer.shared.getTime()
            timeLabel.text = conectLabelandCoreData(label: selectedNames[0], speed: speedMPS)
            timeUnitLabel.text = selectedNames[0]
            
            // Update distance label
            distanceLabel.text = conectLabelandCoreData(label: selectedNames[1], speed: speedMPS)
            distanceUnitLabel.text = selectedNames[1]
        }
    }

    func speakWhenReachingMilestones() {
        if (milestone != 0) {
            let distanceString = WorkoutDataHelper.getDisplayedDistance(from: currentWorkoutDistance)
            let convertedDistance = Double(distanceString)!
            if (convertedDistance > nextMilestone) {
                nextMilestone = convertedDistance + milestone
            }
            if (convertedDistance == nextMilestone) && (convertedDistance > 0) {
                nextMilestone += milestone
                print(nextMilestone)
                TextToSpeech.speakWhenReachingMilestones(workoutDistance: currentWorkoutDistance,
                        workoutTime: GlobalTimer.shared.secondsFormatterToSpokenDuration(
                                                    seconds: GlobalTimer.shared.seconds))
            }
            
        }

    }
    
    @objc func containerTapped(_ sender: UITapGestureRecognizer) {
        print("TAPPED")
        let data: [String] = ["TIME", "DISTANCE", "SPEED", "AVG SPEED", "HEART RATE", "CALLORIES"]
        selectedName = ["\(selectedNames[editedCard!])"]
        // create menu with data source -> here [String]
        let menu = RSSelectionMenu(dataSource: data) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.6811322774)
        }
        // provide selected items
        menu.setSelectedItems(items: selectedName) { (name, index, selected, selectedItems) in
            self.selectedName = selectedItems
        }

        // show dropdown alert
        menu.show(style: .alert(title: "CHANGE CARD NAME", action: "Done", height: 265), from: self)
       
        menu.onDismiss = { [weak self] selectedItems in
            self!.selectedName = selectedItems
            self!.selectedNames[self!.editedCard!] = self?.selectedName[0] as! String
        
            print(self!.selectedNames)
        
        }
        
    }

    func setupContainersTap() {
       let firstContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       firstContainerTap.delegate = self
        
       let secondContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       secondContainerTap.delegate = self
        
       let thirdContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       thirdContainerTap.delegate = self
         
       let fourthContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       fourthContainerTap.delegate = self
        
        
       firstCardLabel.isUserInteractionEnabled = true
       firstCardLabel.addGestureRecognizer(firstContainerTap)
       firstContainerTap.view?.tag = 0
       
       secondCardLabel.isUserInteractionEnabled = true
       secondCardLabel.addGestureRecognizer(secondContainerTap)
       secondContainerTap.view?.tag = 1
        
       thirdCardLabel.isUserInteractionEnabled = true
       thirdCardLabel.addGestureRecognizer(thirdContainerTap)
       thirdContainerTap.view?.tag = 2
        
       fourthCardLabel.isUserInteractionEnabled = true
       fourthCardLabel.addGestureRecognizer(fourthContainerTap)
       fourthContainerTap.view?.tag = 3
        
        
        
    }
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        editedCard = gestureRecognizer.view?.tag
        return true
    }
    
    
    
}

// MARK: Delegate for CLLocationManager
extension MapViewController: CLLocationManagerDelegate {
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        mapLabel.centerToLocation(locations.last!, regionRadius: 300)

        if isTrackingStarted {
            addWorkoutLocations(locations: locations)

            if self.currentLocations.count > 0 {
                locations.forEach { location in
                    let speed = location.speed >= 0.0 ? location.speed : 0.0
                    currentWorkoutSpeedSum += speed
                }
            }
        }
        lastLocation = locations.first!
        altitudeLabel.text = WorkoutDataHelper.getCompleteDisplayedAltitude(from: lastLocation!.altitude)
    }

    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        @unknown default:
            fatalError()
        }
    }

    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    
    
}

// MARK: Delegate for MapViewDelegate
extension MapViewController: MapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        return renderer(mapView, rendererFor: overlay)
    }
}

// MARK: Delegate for SummaryViewControllerDelegate
extension MapViewController: SummaryViewControllerDelegate {
    func showToast (_vc: SummaryViewController) {
        currentWorkout = nil
        ToastView.shared.redToast(view, txt_msg: "Your workout has been saved successfully", duration: 2)
   }
}

// MARK: MKMapView extension to easily change the zoom level (region)
extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate,
                                                  latitudinalMeters: regionRadius,
                                                  longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
}

// MARK: Helper functions
extension MapViewController {
    // Create a new Location object and add to the currentLocations
    // for the started workout
    func addWorkoutLocations(locations: [CLLocation]) {
        guard let workout = currentWorkout else {
            return
        }
        var distance: Double = 0.0
        for location in locations {
            if currentLocations.isEmpty {
                distance = 0
            } else {
                distance = location.distance(from: lastLocation!)
                drawRoute(mapLabel,
                          coordinates: [lastLocation!.coordinate, location.coordinate],
                          animateToRoute: false)
                lastLocation = location
            }

            let workoutLocation =
                DataManager.shared.location(timestamp: Date(), distance: distance,
                                            latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude,
                                            speed: location.speed, altitude: location.altitude,
                                            workout: workout)
            currentLocations.append(workoutLocation)
            currentWorkoutDistance += distance

            // Update milesone and speak when milestone is met
            speakWhenReachingMilestones()
        }
    }

    func averageSpeed() -> Double {
        var averageSpeed = 0.0
        if !currentLocations.isEmpty {
            averageSpeed = currentWorkoutSpeedSum/Double(currentLocations.count)
        }
        return averageSpeed
    }

    func centerToCurrentLocation() {
        if let lastLocation = lastLocation {
        mapLabel.centerToLocation(lastLocation, regionRadius: 300)
        }
    }

    func resetLabels() {
        // Reset distance and averageSpeed
        currentWorkoutDistance = 0.0
        currentWorkoutSpeedSum = 0.0

        timeLabel.text = "00:00:00"
        distanceLabel.text = "0.0"
        speedLabel.text = "0.0"
        averageSpeedLabel.text = "0.0"
    }

    func setMapType() {
        let mapType = UserDefaults.standard.integer(forKey: "MAP")
        switch mapType {
        case Map.satellite.rawValue:
            mapLabel.mapType = .satellite
        case Map.hybrid.rawValue:
            mapLabel.mapType = .hybrid
        case Map.standard.rawValue:
            fallthrough
        default:
            mapLabel.mapType = .standard
        }
    }

    func refreshUnitLabels() {
        distanceUnitLabel.text = "DISTANCE, \(WorkoutDataHelper.getDistanceUnit())"
        let speedFormat = WorkoutDataHelper.getSpeedUnit()
        speedUnitLabel.text = "SPEED, \(speedFormat)"
        averageSpeedUnitLabel.text = "AVG SPEED, \(speedFormat)"
        var altitude = 0.0
        if let lastLocation = lastLocation {
            altitude = lastLocation.altitude
        }
        altitudeLabel.text = WorkoutDataHelper.getCompleteDisplayedAltitude(from: altitude)
    }

    func setupCenterButton() {
        recenterButton.layer.cornerRadius = 25.0
        recenterButton.layer.borderWidth = 1.0
        recenterButton.layer.borderColor = UIColor.black.cgColor
        recenterButton.alpha = 0.8
    }

    func setupSettingsButton() {
        settingButton.layer.cornerRadius = 25.0
        settingButton.layer.borderWidth = 1.0
        settingButton.layer.borderColor = UIColor.black.cgColor
        settingButton.alpha = 0.8
    }

    func setupLocationManager() {
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.distanceFilter = 50
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func setupMapView() {
        mapLabel.showsUserLocation = true
        mapLabel.delegate = self
    }

    func setupWorkoutButton(started: Bool) {
        startButtonLabel.layer.borderWidth = 3
        startButtonLabel.layer.cornerRadius = 10

        if !started {
            startButtonLabel.setTitle("START", for: .normal)
            startButtonLabel.backgroundColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            startButtonLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 1)
        } else {
            startButtonLabel.backgroundColor = #colorLiteral(red: 0.9545200467, green: 0.3107312024, blue: 0.1102497205, alpha: 1)
            startButtonLabel.layer.borderColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            startButtonLabel.setTitle("STOP", for: .normal)
        }
    }

    func startWorkout() {
        locationManager.allowsBackgroundLocationUpdates = true
        centerToCurrentLocation()
        locationManager.distanceFilter = 5
        locationManager.desiredAccuracy = kCLLocationAccuracyBest

        //set up milestone
        
        nextMilestone = milestone
        
        // Start timer
        GlobalTimer.shared.startTimer(self)

        // Create new workout
        currentWorkout = DataManager.shared.workout(timestamp: Date())
        let workoutType = UserDefaults.standard.integer(forKey: keyWorkout)
        currentWorkout!.type = Int16(workoutType)
        if let location = lastLocation {
            addWorkoutLocations(locations: [location])
        }
    }

    func stopWorkout() {
        // Save workout and locations
        if let currentWorkout = currentWorkout {
            currentWorkout.workoutLocations = NSSet(array: currentLocations)
            currentWorkout.comment = ""
            currentWorkout.duration = GlobalTimer.shared.seconds
            currentWorkout.distance = self.currentWorkoutDistance
            currentWorkout.type = WorkoutDataHelper.getWorkoutType()
            currentWorkout.averageSpeed = averageSpeed()
            currentWorkout.speed = WorkoutDataHelper.getMaxSpeed(locations: currentLocations)
            DataManager.shared.save()
            GlobalTimer.shared.stopTimer()
            locationManager.distanceFilter = 50
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer

            if currentLocations.count > 1 {
                var mapLocations: [CLLocationCoordinate2D] = []
                for location in currentLocations {
                    mapLocations.append(CLLocationCoordinate2D(latitude: location.latitude,
                                                               longitude: location.longitude))
                }
                drawRoute(mapLabel, coordinates: mapLocations, animateToRoute: true)
            }
            
            // here to speak final distance
            if (UserDefaults.standard.integer(forKey: "VOICE") == 1) {
                TextToSpeech.speakWhenWorkoutStops(workoutDistance: currentWorkout.distance)}
        }

        currentLocations.removeAll(keepingCapacity: false)
        //set up initial labels
        resetLabels()
        //clean route
        deleteRoute(mapLabel)
        locationManager.allowsBackgroundLocationUpdates = false
    }
    
    func setMilestones() {
           let milestoneKey = UserDefaults.standard.integer(forKey: "VOICE MILESTONES")
           switch milestoneKey {
           case Milestones.off.rawValue:
                 milestone = 0
           case Milestones.half.rawValue:
                milestone = 0.5
           case Milestones.half.rawValue:
                milestone = 1
           case Milestones.half.rawValue:
                milestone = 2
           case Milestones.half.rawValue:
                milestone = 3
           case Milestones.half.rawValue:
                milestone = 4
           case Milestones.half.rawValue:
                milestone = 5
           case Milestones.half.rawValue:
                milestone = 10
           case Map.standard.rawValue:
               fallthrough
           default:
               milestone = 1
           }
       }

}
