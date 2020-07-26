//
//  SummaryViewController.swift
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

protocol SummaryViewControllerDelegate: AnyObject {
    func showToast (_vc: SummaryViewController)
}

class SummaryViewController: UIViewController, UIGestureRecognizerDelegate {
    var delegate: SummaryViewControllerDelegate?
    var currentWorkout: Workout?
    var workoutLocations: [Location] = []
    var allAnnotations: [LocationAnnotation] = []
    static var isSaved = false
    var regionWorkout: MKCoordinateRegion!
    var rectWorkout: MKMapRect!
    var locationCoordinates: [CLLocationCoordinate2D] = []
    var savingSnapshot: Bool = false
    
    static var sender: Int?
    
    @IBOutlet weak var backButtonLabel: UIButton!
    @IBOutlet weak var mapLabel: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var distanceUnitLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var speedUnitLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedUnitLabel: UILabel!

    @IBOutlet weak var writeCommentLabel: UIButton!
    @IBOutlet weak var commentView: UIView!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var distanceContainer: UIView!
    @IBOutlet weak var timeContainer: UIView!
    @IBOutlet weak var shareButtonLabel: UIButton!
    @IBOutlet weak var commentsLabel: UILabel!
    
    @IBAction func backButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        delegate?.showToast(_vc:self)
    }
    
    func setupTextFieldTapGesture() {
        let textFieldTap = UITapGestureRecognizer(target: self, action: #selector(self.textFieldTapped(_:)))
        self.commentsTextView.isUserInteractionEnabled = true
        self.commentsTextView.addGestureRecognizer(textFieldTap)
    }
    
    
    @objc func textFieldTapped(_ sender: UITapGestureRecognizer) {
        commentsTextView.text = currentWorkout?.comment
        commentsTextView.isEditable = true
        commentsTextView.becomeFirstResponder()
        commentsLabel.text = "COMMENTS (tap outside the field to save)"
    }
    
    @IBAction func shareToMedia(_ sender: UIButton) {
        // hide buttons to take screenshot
        backButtonLabel.isHidden = true
        writeCommentLabel.isHidden = true
        shareButtonLabel.isHidden = true
        
        UIGraphicsBeginImageContextWithOptions(view.frame.size, false, UIScreen.main.scale)
        view.layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()!
        
        let imageToShare = [screenshot]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        
        // this fixes the Activity View Controller dismissing the previous view after sharing image in iOS 13
        let fakeViewController = UIViewController()
        fakeViewController.modalPresentationStyle = .overFullScreen

        activityViewController.completionWithItemsHandler = { [weak fakeViewController] _, _, _, _ in
            if let presentingViewController = fakeViewController?.presentingViewController {
                presentingViewController.dismiss(animated: false, completion: nil)
            } else {
                fakeViewController?.dismiss(animated: false, completion: nil)
            }
        }
        present(fakeViewController, animated: true) { [weak fakeViewController] in
            fakeViewController?.present(activityViewController, animated: true, completion: nil)
        }
        
        // show buttons after screenshot
        backButtonLabel.isHidden = false
        writeCommentLabel.isHidden = false
        shareButtonLabel.isHidden = false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupContainersTap()
        setupTextFieldTapGesture()
        mapLabel.delegate = self

        // Init rectWorkout to a valid value as it is not an optional variable
        rectWorkout = mapLabel.visibleMapRect
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func containerTapped(_ sender: UITapGestureRecognizer) {
        ChartViewController.currentWorkout = currentWorkout
        performSegue(withIdentifier: "chartView", sender: nil)
    }

    func setupContainersTap() {
       let timeContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       
       timeContainerTap.delegate = self
       let distanceContainerTap = UITapGestureRecognizer(target: self, action: #selector(self.containerTapped(_:)))
       
       distanceContainerTap.delegate = self
       timeContainer.isUserInteractionEnabled = true
       timeContainer.addGestureRecognizer(timeContainerTap)
       timeContainerTap.view?.tag = 1
       distanceContainer.isUserInteractionEnabled = true
       distanceContainer.addGestureRecognizer(distanceContainerTap)
       distanceContainerTap.view?.tag = 2
    }

    internal func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        SummaryViewController.sender = gestureRecognizer.view?.tag
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // tap gesture to dismiss keyboard
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGestureRecognizer.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGestureRecognizer)
        updateLabels()
        refreshUnitLabels()
        if workoutLocations.count > 1 {
            drawRoute()
        } else if workoutLocations.count == 1 {
            updateMapRegion(location: workoutLocations.first!,
                            rangeSpan: 350)
            setLocationAnnotation(location: workoutLocations.first!)
        }
        SummaryViewController.isSaved = true
        // only save snapshot when initially saving workout
        if savingSnapshot {
            makeSnapshot()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        locationCoordinates.removeAll()
        allAnnotations.removeAll()
        mapLabel.annotations.forEach{mapLabel.removeAnnotation($0)}
        // remove observers otherwise it bugs out
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: self.view.window)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: self.view.window)
    }
    
// MARK: Keyboard Helper functions
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
           return
        }
        self.view.frame.origin.y = 0 - keyboardSize.height
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
            self.view.setNeedsLayout()
        })
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
        UIView.animate(withDuration: 0.8, delay: 0, options: .curveEaseIn, animations: {
            self.view.setNeedsLayout()
        })
    }
    
    @objc func dismissKeyboard(_ gesture: UITapGestureRecognizer) {
        commentsTextView.resignFirstResponder()
        commentsTextView.isEditable = false
    }
    
// MARK: Updating the UI with current workout data
    func updateLabels () {
        workoutLocations = WorkoutDataHelper.sortedLocations(
            locations: currentWorkout!.workoutLocations?.allObjects as! [Location])
        timeLabel.text = GlobalTimer.shared.secondsFormatter(seconds: currentWorkout!.duration)
        distanceLabel.text = WorkoutDataHelper.getDisplayedDistance(
            from: currentWorkout!.distance)
        speedLabel.text = WorkoutDataHelper.getDisplayedMaxSpeed(
            locations: workoutLocations)
        averageSpeedLabel.text = WorkoutDataHelper.getDisplayedSpeed(
            from: currentWorkout!.averageSpeed)
        if (currentWorkout!.comment == "") {
            commentsTextView.text = "Tap to add a comment"
            commentsTextView.textAlignment = .center
        } else {
            commentsTextView.text = currentWorkout!.comment
        }
    }

    func refreshUnitLabels() {
        distanceUnitLabel.text = "DISTANCE, \(WorkoutDataHelper.getDistanceUnit())"
        let speedFormat = WorkoutDataHelper.getSpeedUnit()
        speedUnitLabel.text = "SPEED, \(speedFormat)"
        averageSpeedUnitLabel.text = "AVG SPEED, \(speedFormat)"
    }

    func setLocationAnnotation(location: Location) {
        let coordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let locationAnnotation = LocationAnnotation(coordinate: coordinate2D,
                                                    title: "", subtitle: "")
        mapLabel.addAnnotation(locationAnnotation)
        allAnnotations.append(locationAnnotation)
    }
        
    // draw a path based on all location points
    func drawRoute() {
        for location in workoutLocations {
            setLocationAnnotation(location: location)
            let coordinate = CLLocationCoordinate2DMake(location.latitude, location.longitude)
            locationCoordinates.append(coordinate)
        }
        
        allAnnotations.first?.identifier = "Start"
        allAnnotations.last?.identifier = "End"
            
        let polyline = MKPolyline(coordinates: locationCoordinates, count: locationCoordinates.count)
        
        let padding: CGFloat = 60
        mapLabel.addOverlays([polyline])
            
        let rect = polyline.boundingMapRect
        rectWorkout = rect
        mapLabel.setVisibleMapRect(rect,
            edgePadding: UIEdgeInsets(top: padding*2, left: padding, bottom: padding*2, right: padding),
            animated: false)
    }
        
    func updateMapRegion(location: Location, rangeSpan: CLLocationDistance) {
        let coordinate2D = CLLocationCoordinate2DMake(location.latitude, location.longitude)
        let region = MKCoordinateRegion(center: coordinate2D, latitudinalMeters: rangeSpan, longitudinalMeters: rangeSpan)
        regionWorkout = region
        mapLabel.region = region
    }
        
    deinit {
        mapLabel.annotations.forEach{mapLabel.removeAnnotation($0)}
        mapLabel.delegate = nil
    }
}

// MARK: Delegate for UITextView
extension SummaryViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if let currentWorkout = self.currentWorkout {
            let currentText = textView.text
            if (currentText == "") {
                         commentsTextView.text = "Tap to add a comment"
                currentWorkout.comment = ""
            } else {
                currentWorkout.comment = textView.text
                DataManager.shared.save()
            }
        }
        commentsLabel.text = "COMMENTS"
    }
}

// MARK: Delegate for MKMapView
extension SummaryViewController: MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView = MKPinAnnotationView()
        guard let annotation = annotation as? LocationAnnotation else {
            return nil
        }

        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) as? MKPinAnnotationView {
            annotationView = dequeuedView
        } else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        }

        if annotation.identifier == "Start" {
            annotationView.isHidden = false
            annotationView.pinTintColor = .green
        } else if annotation.identifier == "End" {
            annotationView.isHidden = false
            annotationView.pinTintColor = .red
        } else {
            annotationView.isHidden = true
        }
        annotationView.canShowCallout = false

        return annotationView
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = .systemBlue
        polylineRenderer.lineWidth = 3
        return polylineRenderer
    }
    
    func makeSnapshot()  {
        guard let rectWorkout = rectWorkout else { return}
        let rectWorkoutMap = mapLabel.visibleMapRect
        let options = MKMapSnapshotter.Options()
        let heightSnapshot: CGFloat
        
        //Set up shapshot options
        //Setup snapshot region/rect depends on workoutLocations.count
        if workoutLocations.count == 1 {
            options.region = regionWorkout
        } else {
            //setup snapshot size depends on rect orientation for best resolution
            if rectWorkout.width < rectWorkout.height {
               heightSnapshot = UIScreen.main.bounds.height
               options.size = CGSize(width: heightSnapshot * 1.5, height: heightSnapshot)
            } else {
               heightSnapshot = UIScreen.main.bounds.width
               options.size = CGSize(width: heightSnapshot, height: heightSnapshot / 1.5)
            }
            options.mapRect = rectWorkoutMap
        }
        options.scale = UIScreen.main.scale
        options.showsBuildings = true
        options.pointOfInterestFilter = .includingAll

        //Getting snapshot
        MKMapSnapshotter(options: options).start() { snapshot, error in
            guard let snapshot = snapshot else { return }

            let mapImage = snapshot.image
            //Rendering final shapshot with lines and annotations
            let finalImage = UIGraphicsImageRenderer(size: mapImage.size).image { _ in

                // draw the map image
                mapImage.draw(at: .zero)

                // convert the `[CLLocationCoordinate2D]` into a `[CGPoint]`
                let points = self.locationCoordinates.map { locationCoordinate in
                    snapshot.point(for: locationCoordinate)
                }

                if !points.isEmpty {
                    // build a bezier path using that `[CGPoint]`
                    let path = UIBezierPath()
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }

                    // stroke it
                    path.lineWidth = 5
                    UIColor.blue.setStroke()
                    path.stroke()

                    //annatotions
                    let pinView = MKPinAnnotationView(annotation: nil, reuseIdentifier: nil)
                    let visibleRect = CGRect(origin: CGPoint.zero, size: mapImage .size)

                    var point = points.first!
                    pinView.pinTintColor = .green
                    if visibleRect.contains(point) {
                        point.x = point.x + pinView.centerOffset.x - (pinView.bounds.size.width / 2)
                        point.y = point.y + pinView.centerOffset.y - (pinView.bounds.size.height / 2)
                        pinView.image!.draw(at: point)
                    }

                    point = points.last!
                    pinView.pinTintColor = .red

                    if visibleRect.contains(point) {
                        point.x = point.x + pinView.centerOffset.x - (pinView.bounds.size.width / 2)
                        point.y = point.y + pinView.centerOffset.y - (pinView.bounds.size.height / 2)
                        pinView.image!.draw(at: point)
                    }
                }
            }
            //save final image in CoreData
            let finalImageData = finalImage.pngData()
            if let currentWorkout = self.currentWorkout {
                currentWorkout.image = finalImageData
                DataManager.shared.save()
            }
        }
    }
}
