//
//  SettingSelectionViewControllerDelegate.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit

protocol SettingSelectionViewControllerDelegate: AnyObject {
    func settingChanged(settingTitle: String, selectedValue: String, selectedIndex: Int)
}

class SettingSelectionViewController: UIViewController, CheckTableViewDelegate {

    @IBOutlet weak var settingTableView: UITableView!
    @IBOutlet weak var settingTitleLabel: UILabel!
    
    var choicesList: [String] = []
    var settingTitle: String?
    var selectedValue = 0
    var delegate: SettingSelectionViewControllerDelegate?

    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.settingTableView.tableFooterView = UIView()
        self.settingTableView.allowsSelection = false
        if let settingTitle = settingTitle {
            self.settingTitleLabel.text = settingTitle
        }
    }

    func checkboxSelected(checkbox: CheckTableViewCell, settingValue: String) {
        if settingValue != choicesList[selectedValue] {
            checkbox.check.isChecked = true
            selectedValue = choicesList.firstIndex(of: settingValue) ?? 0

            let cell = settingTableView.cellForRow(at: IndexPath(row: selectedValue,
                                                                 section: 0)) as! CheckTableViewCell
            cell.check.isChecked = false
            settingTableView.reloadData()

            delegate?.settingChanged(settingTitle: self.settingTitle ?? "",
                                     selectedValue: choicesList[selectedValue],
                                     selectedIndex: selectedValue)
        }
    }
}

extension SettingSelectionViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return choicesList.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "checkCell",
                                                 for: indexPath) as! CheckTableViewCell
        cell.set(title: choicesList[indexPath.row],
                 checked: indexPath.row == selectedValue ? true : false)
        cell.cellDelegate = self
        return cell
    }
}

