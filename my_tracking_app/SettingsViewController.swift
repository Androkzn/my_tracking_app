//
//  SettingsViewController.swift
//  my_tracking_app
 //
 //  Created by Andrei Tekhtelev on 2020-07-13.
 //  Copyright © 2020 HomeFoxDev. All rights reserved.
 //

import UIKit

class SettingsViewController: UIViewController {

    @IBOutlet weak var settingsTableView: UITableView!
    
    let settingsValue = [["Metric (meters, kilometers)", "Imperial UK (yards, miles)",
                          "Imperial US (feet, miles)"],
                         [String(describing: WorkoutType.run).capitalized,
                          String(describing: WorkoutType.bike).capitalized,
                          String(describing: WorkoutType.walk).capitalized],
                         [String(describing: Map.standard).capitalized,
                          String(describing: Map.hybrid).capitalized,
                          String(describing: Map.satellite).capitalized],
                         ["Clear history"]]
    var settings: [String: Int]!
    var selectedRow = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settings = [keyUnit:Units.metric.rawValue,
                    keyWorkout:WorkoutType.run.rawValue,
                    keyMap:Map.standard.rawValue,
                    "Other":0]
        retrieveSettings()
        self.settingsTableView.tableFooterView = UIView()
        self.view.backgroundColor = #colorLiteral(red: 0.3285953999, green: 0.7346485257, blue: 0.918245554, alpha: 1)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        return cell
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitle(atIndex: section)
    }
}

// MARK: UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.section

        if indexPath.section != settings.count - 1 {
            // Segue to the second view controller
            self.performSegue(withIdentifier: "settingSelection", sender: self)
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
            let cell = settingsTableView.cellForRow(at: IndexPath(row: 0, section: selectedRow))
            cell?.textLabel?.text = selectedValue
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
        default:
            return "Other"
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
        default:
            return settings["Other"] ?? 0
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
    }

    func saveSetting(key: String) {
        UserDefaults.standard.set(settings[key], forKey: key)
    }

    func clearHistory() {
        let dialogMessage = UIAlertController(title: "Confirm",
                                              message: "Are you sure you want to delete all your workouts?",
                                              preferredStyle: .alert)

        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            DataManager.shared.resetAllRecords(in: "Workout")
            DataManager.shared.resetAllRecords(in: "Location")
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
