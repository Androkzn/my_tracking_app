//
//  SettingsViewController.swift
//  my_tracking_app
 //
 //  Created by Andrei Tekhtelev on 2020-07-13.
 //  Copyright © 2020 HomeFoxDev. All rights reserved.
 //

import UIKit

class SettingsViewController: UIViewController {

    
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var settingsTableView: UITableView!
    
    var headerSetUp = false
    var settingsValue = [["Metric (meters, kilometers)", "Imperial UK (yards, miles)",
                          "Imperial US (feet, miles)"],
                         [String(describing: WorkoutType.walk).capitalized,
                          String(describing: WorkoutType.run).capitalized,
                          String(describing: WorkoutType.bike).capitalized,
                          String(describing: WorkoutType.paddle).capitalized],
                         [String(describing: Map.standard).capitalized,
                          String(describing: Map.hybrid).capitalized,
                          String(describing: Map.satellite).capitalized],
                         ["Off", "On"], ["Off", "0.5 \(WorkoutDataHelper.getDistanceUnit())", "1 \(WorkoutDataHelper.getDistanceUnit())", "2 \(WorkoutDataHelper.getDistanceUnit())", "3 \(WorkoutDataHelper.getDistanceUnit())", "4 \(WorkoutDataHelper.getDistanceUnit())", "5 \(WorkoutDataHelper.getDistanceUnit())", "10 \(WorkoutDataHelper.getDistanceUnit())"], ["Clear history"]]
    var settings: [String: Int]!
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = [keyUnit:Units.metric.rawValue,
                    keyWorkout:WorkoutType.run.rawValue,
                    keyMap:Map.standard.rawValue, keyVoice: Voice.off.rawValue,keyMilestones: Milestones.one.rawValue,
                    "Other":0]
        retrieveSettings()
        self.settingsTableView.tableFooterView = UIView()
        self.view.backgroundColor = #colorLiteral(red: 0.3285953999, green: 0.7346485257, blue: 0.918245554, alpha: 1)
        
        //prints path to settings data
        let library_path = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0]
        print("library path is \(library_path)")
        //set vesion
        versionLabel.text = "v. \(WorkoutDataHelper.getVersion())"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        settingsValue = [["Metric (meters, kilometers)", "Imperial UK (yards, miles)",
         "Imperial US (feet, miles)"],
        [String(describing: WorkoutType.walk).capitalized,
        String(describing: WorkoutType.run).capitalized,
        String(describing: WorkoutType.bike).capitalized,
        String(describing: WorkoutType.paddle).capitalized],
        [String(describing: Map.standard).capitalized,
         String(describing: Map.hybrid).capitalized,
         String(describing: Map.satellite).capitalized],
        ["Off", "On"], ["Off", "0.5 \(WorkoutDataHelper.getDistanceUnit())", "1 \(WorkoutDataHelper.getDistanceUnit())", "2 \(WorkoutDataHelper.getDistanceUnit())", "3 \(WorkoutDataHelper.getDistanceUnit())", "4 \(WorkoutDataHelper.getDistanceUnit())", "5 \(WorkoutDataHelper.getDistanceUnit())", "10 \(WorkoutDataHelper.getDistanceUnit())"], ["Clear history"]]
        //reloads the TableView
        self.settingsTableView.reloadData()
    }
    
    @IBAction func backSelected(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBSegueAction func editSetting(_ coder: NSCoder) -> UIViewController? {
        let settingVC = SettingSelectionViewController(coder: coder)
        settingVC?.choicesList = settingsValue[selectedRow]
        settingVC?.selectedValue = settingSelection(atIndex: selectedRow)
        settingVC?.settingTitle = sectionTitle(atIndex: selectedRow)
        settingVC?.delegate = self
        return settingVC
    }
}

// MARK: UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cell: UITableViewCell
        cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel!.text = settingTitle(atIndex: indexPath.section)
        cell.textLabel!.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
        tableView.rowHeight = 50.0
        return cell
    }
    
    //set up section title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle(atIndex: section)
    }
    
    //set up cell header height
    func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
    //set up cell header with icon
//        func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        if !headerSetUp {
//            let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
//            //set up image
//            let imageName = "icons8-mountain-100.png"
//            let image = UIImage(named: imageName)
//            let imageView = UIImageView(image: image!)
//            imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
//            imageView.tintColor  = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
//            //set up label
//            let title = UILabel()
//            title.text = sectionTitle(atIndex: section)
//            title.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.bold)
//
//            //set up header constraints
//            imageView.translatesAutoresizingMaskIntoConstraints = false
//            title.translatesAutoresizingMaskIntoConstraints = false
//
//            header.addSubview(imageView)
//            header.addSubview(title)
//            NSLayoutConstraint.activate([
//                imageView.leadingAnchor.constraint(equalTo: header.layoutMarginsGuide.leadingAnchor),
//                imageView.widthAnchor.constraint(equalToConstant: 30),
//                imageView.heightAnchor.constraint(equalToConstant: 30),
//                imageView.centerYAnchor.constraint(equalTo: header.centerYAnchor),
//
//                // Center the label vertically, and use it to fill the remaining space in the header view.
//                title.heightAnchor.constraint(equalToConstant: 30),
//                title.leadingAnchor.constraint(equalTo: imageView.trailingAnchor,
//                       constant: 8),
//                title.trailingAnchor.constraint(equalTo:
//                       header.layoutMarginsGuide.trailingAnchor),
//                title.centerYAnchor.constraint(equalTo: header.centerYAnchor)
//            ])
//
//        }
//    }
    
}

// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.section
        if indexPath.section != settings.count - 1 {
            // Segue to the second view controller
            self.performSegue(withIdentifier: "settingSelection", sender: self)
            headerSetUp = true
        } else {
            // Show a confirmation dialog to delete all workouts.
            clearHistory()
        }
    }
}

// MARK: SettingSelectionViewControllerDelegate
extension SettingsViewController: SettingSelectionViewControllerDelegate {
    func settingChanged(settingTitle: String, selectedValue: String, selectedIndex: Int) {
        if sectionTitle(atIndex: selectedRow) == settingTitle {
            //let cell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: selectedRow))
            //cell?.textLabel?.text = selectedValue
            //cell?.textLabel?.font = UIFont.systemFont(ofSize: 40, weight: UIFont.Weight.bold)
            let key = sectionTitle(atIndex: selectedRow)
            settings[key] = selectedIndex
            saveSetting(key: sectionTitle(atIndex: selectedRow))
        }
    }
}

extension SettingsViewController {
    func sectionTitle(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return keyUnit
        case 1:
            return keyWorkout
        case 2:
            return keyMap
        case 3:
            return keyVoice
        case 4:
            return keyMilestones
        default:
            return "OTHER"
        }
    }

    func settingTitle(atIndex: Int) -> String {
        switch atIndex {
        case 0:
            return settingsValue[atIndex][settings[keyUnit] ?? 0]
        case 1:
            return settingsValue[atIndex][settings[keyWorkout] ?? 0]
        case 2:
            return settingsValue[atIndex][settings[keyMap] ?? 0]
        case 3:
            return settingsValue[atIndex][settings[keyVoice] ?? 0]
        case 4:
            return settingsValue[atIndex][settings[keyMilestones] ?? 0]
        default:
            return settingsValue[atIndex][0]
        }
    }

    func settingSelection(atIndex: Int) -> Int {
        switch atIndex {
        case 0:
            return settings[keyUnit] ?? 0
        case 1:
            return settings[keyWorkout] ?? 0
        case 2:
            return settings[keyMap] ?? 0
        case 3:
            return settings[keyVoice] ?? 0
        case 4:
            return settings[keyMilestones] ?? 0
        default:
            return settings["OTHER"] ?? 0
        }
    }
    

    func retrieveSettings() {
        let defaults = UserDefaults.standard
        settings[keyUnit] = defaults.integer(forKey: keyUnit)
        if settings[keyUnit] == 0 {
            defaults.set(settings[keyUnit], forKey: keyUnit)
        }
        settings[keyWorkout] = defaults.integer(forKey: keyWorkout)
        if settings[keyWorkout] == 0 {
            defaults.set(settings[keyWorkout], forKey: keyWorkout)
        }
        settings[keyMap] = defaults.integer(forKey: keyMap)
        if settings[keyMap] == 0 {
            defaults.set(settings[keyMap], forKey: keyMap)
        }
        settings[keyVoice] = defaults.integer(forKey: keyVoice)
        if settings[keyVoice] == 0 {
            defaults.set(settings[keyVoice], forKey: keyVoice)
        }
        settings[keyMilestones] = defaults.integer(forKey: keyMilestones)
        if settings[keyMilestones] == 0 {
            defaults.set(settings[keyMilestones], forKey: keyMilestones)
        }
    }

    func saveSetting(key: String) {
        UserDefaults.standard.set(settings[key], forKey: key)
    }

    func clearHistory() {
        let dialogMessage = UIAlertController(title: "Confirm",
                                              message: "Are you sure you want to delete all your workouts?",
                                              preferredStyle: .alert)
        //set up background color and button color
        dialogMessage.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 1, green: 0.8076083209, blue: 0.4960746166, alpha: 0.8323255565)
        dialogMessage.view.tintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            DataManager.shared.resetAllRecords(in: "Workout")
            DataManager.shared.resetAllRecords(in: "Location")
            ToastView.shared.blueToast(self.view,
            txt_msg: "All your existing workouts has been deleted successfully",
            duration: 4)
        })

        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
        }

        //Add OK and Cancel button to dialog message
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)

        // Present dialog message to user
        self.present(dialogMessage, animated: true, completion: nil)
    }
}
