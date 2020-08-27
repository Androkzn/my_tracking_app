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

    @IBOutlet weak var firstCardLabel: UILabel!
    @IBOutlet weak var firstCardUnitLabel: UILabel!
    @IBOutlet weak var firstCardView: UIView!
    
    @IBOutlet weak var secondCardLabel: UILabel!
    @IBOutlet weak var secondCardUnitLabel: UILabel!
    @IBOutlet weak var secondCardView: UIView!

    @IBOutlet weak var thirdCardLabel: UILabel!
    @IBOutlet weak var thirdCardUnitLabel: UILabel!
    @IBOutlet weak var thirdCardView: UIView!

    @IBOutlet weak var fourthCardLabel: UILabel!
    @IBOutlet weak var fourthCardUnitLabel: UILabel!
    @IBOutlet weak var fourthCardView: UIView!
    
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var counterTextLabel: UILabel!
    @IBOutlet weak var progressBarLabel: UIProgressView!
    @IBOutlet weak var iconAltitudeLabel: UIImageView!
    @IBOutlet weak var altitudeLabel: UILabel!
    @IBOutlet weak var workoutTypeLabel: UIImageView!
    
    
    @IBOutlet weak var bannerView: UIView!
    @IBOutlet weak var bannerTitleLabel: UILabel!
    @IBOutlet weak var bannerBodyLabel: UILabel!
    @IBOutlet weak var bannerPageControlLabel: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var backgroundBanerView: UIView!
    
    
    //Variables
    var isTrackingStarted = false
    var currentLocations: [Location] = [] // Current workout locations
    var currentWorkout: Workout? // Reset only when we're back from SummaryViewController
    var currentWorkoutDistance = 0.0 // Raw distance in meters
    var currentWorkoutSpeedSum = 0.0 // Addition of raw speeds in meter per second
    var counter = 1.0 //stop button timer counter
    var lastLocation: CLLocation?
    var locationManager: CLLocationManager!
    var overlays: [MKPolyline] = [] // From MapViewDelegate protocol, workout route
    var nextMilestone: Double = 0.0 // The closest milestone after reaching E.g. 1 mile, 2 miles, etc.
    var milestone: Double = 0.0 //Milstone from settings
    var editedCard: Int? //Stores value of edited card tag
    var selectedName: [String] = [] //selected card name after editing
    var bannerBodyes: [String] = [] //stores banner's bodyes
    var bannerBodyIndex = 0
 
    override func viewDidLoad() {
        super.viewDidLoad()
        setCardsSettings()
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
        setupWorkoutTypeTap()
        setWorkoutType ()
        Watch.shared.checkWatchConnection()
        setUpBannerScrollView()
        showBanner ()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setMilestones()
        setMapType()
        centerToCurrentLocation()
        updateLabels()
        showSavedWorkoutToast()
        setUpAltitudeLaberl ()
        updatesWorkoutTypeIcon ()
        setCardsSettings()
    }
    
    
    
    @IBAction func closeBannerButton(_ sender: Any) {
        let dialogMessage = UIAlertController(title: "Do you want to know about our new features?",
                                              message: " ",
                                              preferredStyle: .alert)
        
        //set up background color and button color
        dialogMessage.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 1, green: 0.8076083209, blue: 0.4960746166, alpha: 0.8323255565)
        dialogMessage.view.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        
        // Create Don't show again button with action handler
        let ok = UIAlertAction(title: "Don't show again", style: .default, handler: { (action) -> Void in
            self.bannerView.isHidden = true
            self.backgroundBanerView.isHidden = true
            UserDefaults.standard.set("false", forKey: "FirstSeenBanner")
            
        })

        // Create Review later button with action handlder
        let cancel = UIAlertAction(title: "Review later", style: .cancel) { (action) -> Void in
            self.bannerView.isHidden = true
            self.backgroundBanerView.isHidden = true
        }

        //Add Don't show again and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)

        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
        
    }
    
    func setUpBannerScrollView() {
        //set up banner var in defaults
        if UserDefaults.standard.object(forKey: "FirstSeenBanner") == nil {
            UserDefaults.standard.set("true", forKey: "FirstSeenBanner")
        }
        //set up banner's border
        bannerView.layer.cornerRadius = 10
        bannerView.layer.borderWidth = 1.0
        bannerView.layer.borderColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        
        //set up title's border
        bannerTitleLabel.layer.cornerRadius = 10
        bannerTitleLabel.layer.borderWidth = 1.0
        bannerTitleLabel.layer.backgroundColor = #colorLiteral(red: 1, green: 0.8085083365, blue: 0.4892358184, alpha: 1)
        bannerTitleLabel.layer.borderColor = #colorLiteral(red: 1, green: 0.580126236, blue: 0.01286631583, alpha: 0.5366010274)
       
        //set up title's depends on current version
        bannerTitleLabel.text = "What is new in version \(WorkoutDataHelper.getVersion())?"
        
        //set up ScrollView constraints
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.heightAnchor.constraint(equalTo:  scrollView.widthAnchor, multiplier: 1050/1237).isActive = true
        scrollView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        let constraints = [
            NSLayoutConstraint(item: scrollView!, attribute: .top, relatedBy: .equal, toItem: bannerBodyLabel, attribute: .bottom, multiplier: 1, constant: 15),
            NSLayoutConstraint(item: scrollView!, attribute: .bottom, relatedBy: .equal, toItem: bannerPageControlLabel, attribute: .top, multiplier: 1, constant: -15),
            NSLayoutConstraint(item: scrollView!, attribute: .leading, relatedBy: .equal, toItem: bannerView, attribute: .leading, multiplier: 1, constant: 20),
            NSLayoutConstraint(item: scrollView!, attribute: .trailing, relatedBy: .equal, toItem: bannerView, attribute: .leading, multiplier: 1, constant: 10)
        ]
        constraints[2].priority = UILayoutPriority(rawValue: 999)
        constraints[3].priority = UILayoutPriority(rawValue: 999)
        NSLayoutConstraint.activate(constraints)
        
        //set up set of images for the banner
        let imageViews = [
            UIImageView(image: UIImage(named: "banner1")),
            UIImageView(image: UIImage(named: "banner2")),
            UIImageView(image: UIImage(named: "banner3")),
            UIImageView(image: UIImage(named: "banner4")),
            UIImageView(image: UIImage(named: "banner5"))
        ]
        //set up set of bodies for the banner
        bannerBodyes = ["Customizable cards' set. Change the order and pick what important to you.", "Four different types of workout use unique algorithms for calculating paddles, steps, and calories.", "Graphs provide extended analytics after a workout.", "We protect your workout from stoping accidentally. It stops when you stop it.", "The app can speak to you. Voice prompts will tell you about reaching 'milestones' during a workout." ]
        
        imageViews.forEach { imageView in
            imageView.contentMode = .scaleToFill
            imageView.clipsToBounds = true
        }
        
        let stackView = UIStackView (arrangedSubviews: imageViews)
        stackView.backgroundColor = UIColor.orange
        stackView.axis = .horizontal
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        
        NSLayoutConstraint.activate([
          stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
          stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
          stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
          stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
        
          stackView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, multiplier:  1),
          stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, multiplier:  CGFloat(Double(imageViews.count))),
        ])
        
    }
    
    func showBanner () {
        if UserDefaults.standard.string(forKey: "FirstSeenBanner") == "true" {
            self.bannerView.isHidden = false
            self.backgroundBanerView.isHidden = false
        } else {
            self.bannerView.isHidden = true
            self.backgroundBanerView.isHidden = true
        }
    }
    
    func checkProfile () -> Bool {
        var  profileFilledOut = false
        
        if UserDefaults.standard.object(forKey: "AGE") == nil || UserDefaults.standard.object(forKey: "GENDER") == nil || UserDefaults.standard.object(forKey: "WEIGHT") == nil || UserDefaults.standard.object(forKey: "HEIGHT") == nil || UserDefaults.standard.string(forKey: "AGE") == "" || UserDefaults.standard.string(forKey: "GENDER") == "" || UserDefaults.standard.string(forKey: "WEIGHT") == "" || UserDefaults.standard.string(forKey: "HEIGHT") == ""{
                let dialogMessage = UIAlertController(title: "Please fill out Profile information to be able to get an accurate callories, steps and paddles",
                                                          message: " ",
                                                          preferredStyle: .alert)
                //set up background color and button color
                dialogMessage.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 1, green: 0.8076083209, blue: 0.4960746166, alpha: 0.8323255565)
                dialogMessage.view.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            
                // Create OK button with action handler
                let ok = UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
 
                })

                // Create Cancel button with action handlder
                let cancel = UIAlertAction(title: "Go to Profile", style: .cancel) { (action) -> Void in
                    self.tabBarController!.selectedIndex = 2
                }

                //Add OK and Cancel button to dialog message
                dialogMessage.addAction(ok)
                dialogMessage.addAction(cancel)

                // Present dialog message to user
                self.present(dialogMessage, animated: true, completion: nil)
        } else {
            profileFilledOut = true
        }
        return profileFilledOut
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
            workoutTypeLabel.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        } else {
            altitudeLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            iconAltitudeLabel.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            workoutTypeLabel.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        }
    }
    
    //set up labels from Core Data
    func conectLabelandCoreData (label: String, speed: CLLocationSpeed)  -> [String] {
        var data: [String] = ["",""]
        let labelUpdated = updatesLabelDependsOnWorkoutType(label: label)

        
        if labelUpdated == "TIME" {
            data[0] = GlobalTimer.shared.getTime()
            data[1] = ""
        }
        //Updates distance label depends on workout type
        if WorkoutDataHelper.getWorkoutType() == 2 {
            //Source of data is GPS
            if labelUpdated == "DISTANCE" {
                data[0] = WorkoutDataHelper.getDisplayedDistance(from: currentWorkoutDistance)
                data[1] = ", \(WorkoutDataHelper.getDistanceUnit())"
            }
        }
        else {
            //Source of data is pedometer
            if labelUpdated == "DISTANCE" {
                data[0] = WorkoutDataHelper.getDisplayedDistance(from: DeviceMotion.shared.distance)
                data[1] = ", \(WorkoutDataHelper.getDistanceUnit())"
            }
        }
        if labelUpdated == "SPEED" {
            data[0] = WorkoutDataHelper.getDisplayedSpeed(from: speed)
            data[1] = ", \(WorkoutDataHelper.getSpeedUnit())"
        }
        if labelUpdated == "AVG SPEED" {
            data[0] = WorkoutDataHelper.getDisplayedSpeed(from: averageSpeed())
            data[1] = ", \(WorkoutDataHelper.getSpeedUnit())"
        }
        if labelUpdated == "PADDLES" {
            data[0] = "0"
            data[1] = ""
        }
        if labelUpdated == "STEPS" {
            data[0] = "\(DeviceMotion.shared.steps)"
            data[1] = ""
        }
        if labelUpdated == "HEART RATE" {
            data[0] = "\(HealthData.shared.heartRate)"
            data[1] = ", bpm"
            
        }
        if labelUpdated == "CALLORIES" {
            data[0] = "\(WorkoutDataHelper.getCallories(workout: currentWorkout!, seconds: GlobalTimer.shared.seconds))"
            data[1] = ", kcal"
            
        }
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

    
    
    //center map button
    @IBAction func centerMap(_ sender: UIButton) {
        centerToCurrentLocation()
    }
    
    //start button state
    @objc func startButton(_ sender: UITapGestureRecognizer) {
        // Start new workout button pressed
        if lastLocation != nil {
            if !isTrackingStarted {
                if checkProfile () { 
                    isTrackingStarted = !isTrackingStarted
                    setupWorkoutButton(started: isTrackingStarted)
                    startWorkout()
                }
            } else {
                ToastView.shared.redToast(view, txt_msg: "Long Press STOP button for 2 seconds to stop workout", duration: 3)
            }
        } else {
            ToastView.shared.redToast(view,
            txt_msg: "Your location service is not available, please enable Location on your device",
            duration: 2)
        }
    }
    
    //stop button state
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
    
    //controls popup behaviour when stop button is long pressed
    func setupCounterLabel (started: Bool) {
        counterTextLabel.layer.backgroundColor = #colorLiteral(red: 0.3249011148, green: 0.7254286438, blue: 0.9069467254, alpha: 0.8043396832)
        counterTextLabel.layer.cornerRadius = 10
        counterTextLabel.layer.borderWidth = 1.0
        counterTextLabel.layer.borderColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
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
        
        //Gets heart  rate
        HealthData.shared.latestHeartRate(seconds: GlobalTimer.shared.seconds)
        
        //Gets burned callories
        HealthData.shared.latestEnergyBurned(seconds:GlobalTimer.shared.seconds)
        
        //Gets steps from pedometer
        DeviceMotion.shared.getSteps(seconds: GlobalTimer.shared.seconds)
        
        if let lastLocation = lastLocation {
            // Prepare UserDefauld instance
            let defaults = UserDefaults.standard
            // Update speed labels
            speedMPS = lastLocation.speed >= 0.0 ? lastLocation.speed : 0.0
            thirdCardLabel.text = conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 2))!, speed: speedMPS)[0]
            thirdCardUnitLabel.text = updatesLabelDependsOnWorkoutType(label: defaults.string(forKey: cards(atIndex: 2))!) + conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 2))!, speed: speedMPS)[1]
            fourthCardLabel.text = conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 3))!, speed: speedMPS)[0]
            fourthCardUnitLabel.text = updatesLabelDependsOnWorkoutType(label: defaults.string(forKey: cards(atIndex: 3))!) +  conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 3))!, speed: speedMPS)[1]
            //Update altitude label
            altitudeLabel.text = WorkoutDataHelper.getCompleteDisplayedAltitude(from: lastLocation.altitude)
            // Update timer label
            firstCardLabel.text = conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 0))!, speed: speedMPS)[0]
            firstCardUnitLabel.text = updatesLabelDependsOnWorkoutType(label: defaults.string(forKey: cards(atIndex: 0))!) + conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 0))!, speed: speedMPS)[1]
            // Update distance label
            secondCardLabel.text = conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 1))!, speed: speedMPS)[0]
            secondCardUnitLabel.text = updatesLabelDependsOnWorkoutType(label: defaults.string(forKey: cards(atIndex: 1))!) + conectLabelandCoreData(label: defaults.string(forKey: cards(atIndex: 1))!, speed: speedMPS)[1]
        }
    }

    //activate text to speach when a milestone is reached
    func speakWhenReachingMilestones() {
        if (milestone != 0) {
            let distanceString = WorkoutDataHelper.getDisplayedDistance(from: currentWorkoutDistance)
            let convertedDistance = Double(distanceString)!
            if (convertedDistance > nextMilestone) {
                nextMilestone = convertedDistance + milestone
            }
            if (convertedDistance == nextMilestone) && (convertedDistance > 0) {
                nextMilestone += milestone
                TextToSpeech.speakWhenReachingMilestones(workoutDistance: currentWorkoutDistance,
                        workoutTime: GlobalTimer.shared.secondsFormatterToSpokenDuration(
                                                    seconds: GlobalTimer.shared.seconds))
            }
            
        }

    }
    
    //
    @objc func containerTapped(_ sender: UITapGestureRecognizer) {
        var data: [String] = []
         if  WorkoutDataHelper.getWorkoutType() == 2 {
             data = ["TIME", "DISTANCE", "SPEED", "AVG SPEED", "HEART RATE", "CALLORIES"]
         } else if WorkoutDataHelper.getWorkoutType() == 3 {
             data = ["TIME", "DISTANCE", "SPEED", "AVG SPEED", "PADDLES", "HEART RATE", "CALLORIES"]
         } else {
             data = ["TIME", "DISTANCE", "SPEED", "AVG SPEED", "STEPS", "HEART RATE", "CALLORIES"]
         }
        
        // Prepare UserDefauld instance
        let defaults = UserDefaults.standard
        selectedName = ["\(defaults.string(forKey: cards(atIndex: editedCard!))!)"]
         
        // create menu with data source -> here [String]
        let menu = RSSelectionMenu(dataSource: data) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
            cell.textLabel?.textColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.6811322774)
            cell.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        }
        
        // provide selected items
        menu.setSelectedItems(items: selectedName) { (name, index, selected, selectedItems) in
            self.selectedName = selectedItems
        }
        
        // show dropdown alertpopover
        let label = [firstCardUnitLabel, secondCardUnitLabel, thirdCardUnitLabel, fourthCardUnitLabel]
        if  WorkoutDataHelper.getWorkoutType() == 2 {
            menu.show(style: .popover(sourceView: label[editedCard!]!, size: CGSize(width: 200, height: 220)), from: self)
        } else {
            menu.show(style: .popover(sourceView: label[editedCard!]!, size: CGSize(width: 200, height: 265)), from: self)
        }
        menu.onDismiss = { [self] selectedItems in
            self.selectedName = selectedItems
            UserDefaults.standard.set(self.selectedName[0], forKey: self.cards(atIndex: self.editedCard!))
            self.resetLabels()
            if self.isTrackingStarted == false {
                self.updateLabels()
                print("Labels was updated")
            }
        }
        
    }
    
    
    func cards(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return firstCard
        case 1:
            return secondCard
        case 2:
            return thirdCard
        case 3:
            return fourthCard
        default:
             return firstCard
        }
    }
    
    func setCardsSettings() {
        if UserDefaults.standard.object(forKey: "FirstCard") == nil {
            UserDefaults.standard.set("TIME", forKey: cards(atIndex: 0))
            UserDefaults.standard.set("DISTANCE", forKey: cards(atIndex: 1))
            UserDefaults.standard.set("SPEED", forKey: cards(atIndex: 2))
            UserDefaults.standard.set("AVG SPEED", forKey: cards(atIndex: 3))
        } else {
            updateLabels()
        }
    }
    

    func setupContainersTap() {
       let firstContainerTap = UILongPressGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       firstContainerTap.delegate = self
        
       let secondContainerTap = UILongPressGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       secondContainerTap.delegate = self
        
       let thirdContainerTap = UILongPressGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       thirdContainerTap.delegate = self
         
       let fourthContainerTap = UILongPressGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       fourthContainerTap.delegate = self
        
        
       firstCardView.isUserInteractionEnabled = true
       firstCardView.addGestureRecognizer(firstContainerTap)
       firstContainerTap.view?.tag = 0
       
       secondCardView.isUserInteractionEnabled = true
       secondCardView.addGestureRecognizer(secondContainerTap)
       secondContainerTap.view?.tag = 1
        
       thirdCardView.isUserInteractionEnabled = true
       thirdCardView.addGestureRecognizer(thirdContainerTap)
       thirdContainerTap.view?.tag = 2
        
       fourthCardView.isUserInteractionEnabled = true
       fourthCardView.addGestureRecognizer(fourthContainerTap)
       fourthContainerTap.view?.tag = 3
        
    }
    
    
    func sectionWorkout(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return "WALK"
        case 1:
            return "RUN"
        case 2:
            return "BIKE"
        case 3:
            return "PADDLE"
        default:
            return "WALK"
        }
    }
    
    func setWorkoutType () {
        let defaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: "WORKOUT") == nil  {
            defaults.set("0", forKey: "WORKOUT")
        }
    }
    
    
    @objc func workoutTypeTapped(_ sender: UITapGestureRecognizer) {
        let data: [String] = ["WALK", "RUN", "BIKE", "PADDLE"]
        var selectedIndex = 0
        
        let defaults = UserDefaults.standard
        let workoutType = Int(defaults.string(forKey: "WORKOUT")!)!
        selectedName = ["\(sectionWorkout(atIndex: workoutType))"]
         
        // create menu with data source -> here [String]
        let menu = RSSelectionMenu(dataSource: data) { (cell, name, indexPath) in
            cell.textLabel?.text = name
            cell.textLabel?.font = UIFont.systemFont(ofSize: 15, weight: UIFont.Weight.bold)
            cell.textLabel?.textColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
            cell.backgroundColor = #colorLiteral(red: 1, green: 0.5763723254, blue: 0, alpha: 0.6811322774)
            cell.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        }
        
        // provide selected items
        menu.setSelectedItems(items: selectedName) { (name, index, selected, selectedItems) in
            self.selectedName = selectedItems
            selectedIndex = index
        }
    
        menu.show(style: .popover(sourceView: workoutTypeLabel!, size: CGSize(width: 200, height: 130)), from: self)

        
        menu.onDismiss = { [self] selectedItems in
            self.selectedName = selectedItems
            UserDefaults.standard.set(selectedIndex, forKey: "WORKOUT")
            self.currentWorkout!.type = WorkoutDataHelper.getWorkoutType()
            self.updatesWorkoutTypeIcon ()
            if self.isTrackingStarted == false {
                self.updateLabels()
                print("Labels was updated")
            }
        }
        
    }
    
    
    func setupWorkoutTypeTap() {
       let workoutTypeTap = UILongPressGestureRecognizer(target: self, action: #selector(self.workoutTypeTapped(_:)))
       workoutTypeTap.delegate = self
    
       workoutTypeLabel.isUserInteractionEnabled = true
       workoutTypeLabel.addGestureRecognizer(workoutTypeTap)
        
    }
    
    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        editedCard = gestureRecognizer.view?.tag
        return true
    }
    
    func updatesWorkoutTypeIcon () {
        if  WorkoutDataHelper.getWorkoutType() == 0 {
            workoutTypeLabel.image = UIImage(named: "walk")
        }
        if  WorkoutDataHelper.getWorkoutType() == 1 {
            workoutTypeLabel.image = UIImage(named: "run")
        }
        if  WorkoutDataHelper.getWorkoutType() == 2 {
            workoutTypeLabel.image = UIImage(named: "cycling")
        }
        if  WorkoutDataHelper.getWorkoutType() == 3 {
            workoutTypeLabel.image = UIImage(named: "paddling")
        }
    }
    
    func setupWorkoutButton(started: Bool) {
        startButtonLabel.layer.borderWidth = 1.5
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

        //request autorization
        HealthData.shared.requestAutorization()
        
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
            currentWorkout.steps = DeviceMotion.shared.steps
            currentWorkout.workoutLocations = NSSet(array: currentLocations)
            currentWorkout.comment = ""
            currentWorkout.duration = GlobalTimer.shared.seconds
            //Saves distance depends on workout type
            if WorkoutDataHelper.getWorkoutType() == 2 {
                //Source of data is GPS
                currentWorkout.distance = self.currentWorkoutDistance
            } else {
                //Source of data is pedometer
                currentWorkout.distance = DeviceMotion.shared.distance
            }
            currentWorkout.type = WorkoutDataHelper.getWorkoutType()
            currentWorkout.averageSpeed = averageSpeed()
            currentWorkout.speed = WorkoutDataHelper.getMaxSpeed(locations: currentLocations)
            currentWorkout.calories = Int16(WorkoutDataHelper.getCallories(workout: currentWorkout, seconds: GlobalTimer.shared.seconds))!
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
        //Reset data
        HealthData.shared.totalSteps = 0
        HealthData.shared.totalCaloriesBurned = 0
        HealthData.shared.heartRate = 0
        DeviceMotion.shared.steps = 0
        DeviceMotion.shared.distance = 0
        
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
    
    func resetLabels() {
        // Reset distance and averageSpeed
        //currentWorkoutDistance = 0.0
        //currentWorkoutSpeedSum = 0.0
        updateLabels()

    }
    
    func updateLabels() {
        // Prepare UserDefauld instance
        let defaults = UserDefaults.standard
        // Update timer label
        firstCardLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 0))!)[0]
        firstCardUnitLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 0))!)[1]
        // Update distance label
        secondCardLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 1))!)[0]
        secondCardUnitLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 1))!)[1]
        // Update speed label
        thirdCardLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 2))!)[0]
        thirdCardUnitLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 2))!)[1]
        // Update avg speed label
        fourthCardLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 3))!)[0]
        fourthCardUnitLabel.text = updateAllLabels(label: defaults.string(forKey: cards(atIndex: 3))!)[1]
    }
    
  
    func updatesLabelDependsOnWorkoutType (label: String) -> String {
        var label = label
        if WorkoutDataHelper.getWorkoutType() == 3 && label == "STEPS" {
            label = "PADDLES"
        } else if (WorkoutDataHelper.getWorkoutType() == 0 && label == "PADDLES") || (WorkoutDataHelper.getWorkoutType() == 1 && label == "PADDLES") {
            label = "STEPS"
        } else if (WorkoutDataHelper.getWorkoutType() == 2 && label == "PADDLES") || (WorkoutDataHelper.getWorkoutType() == 2 && label == "STEPS") {
            label = "HEART RATE"
        }
        return label
    }
    
    func updateAllLabels (label: String)  -> [String] {
        let label = updatesLabelDependsOnWorkoutType(label: label)
        var data: [String] = ["",""]
        if label == "TIME" {
            data[0] = "00:00:00"
            data[1] = "TIME"
        }
        if label == "DISTANCE" {
            data[0] = "0.0"
            data[1] = "DISTANCE, \(WorkoutDataHelper.getDistanceUnit())"
        }
        if label == "SPEED" {
            data[0] = "0.0"
            data[1] = "SPEED, \(WorkoutDataHelper.getSpeedUnit())"
        }
        if label == "AVG SPEED" {
            data[0] = "0.0"
            data[1] = "AVG SPEED, \(WorkoutDataHelper.getSpeedUnit())"
        }
        if label == "PADDLES" {
            data[0] = "0"
            data[1] = "PADDLES"
        }
        if label == "STEPS" {
            data[0] = "0"
            data[1] = "STEPS"
        }
        if label == "HEART RATE" {
            data[0] = "0"
            data[1] = "HEART RATE, bpm"
        }
        if label == "CALLORIES" {
            data[0] = "0"
            data[1] = "CALLORIES, kcal"
        }
        return data
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
            print("location.horizontalAccuracy: \(location.horizontalAccuracy)")
            if location.horizontalAccuracy < 20 {
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

    func setupLocationManager() {
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 50
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.startUpdatingLocation()
    }

    func setupMapView() {
        mapLabel.showsUserLocation = true
        mapLabel.delegate = self
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
    
}

//updates page control depending on scrollView's image
extension MapViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = Int(round(scrollView.contentOffset.x/scrollView.frame.width))
        print(page)
        bannerPageControlLabel.currentPage = page
        bannerBodyIndex = page
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        bannerBodyLabel.text = bannerBodyes[bannerBodyIndex]
    }
}
