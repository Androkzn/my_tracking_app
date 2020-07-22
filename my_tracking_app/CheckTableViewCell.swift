//
//  CheckTableViewCell.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit

protocol CheckTableViewDelegate: AnyObject {
    func checkboxSelected(checkbox: CheckTableViewCell, settingValue: String)
}

class CheckTableViewCell: UITableViewCell {

    @IBOutlet weak var check: Checkbox!
    @IBOutlet weak var titleLabel: UILabel!

    var cellDelegate: CheckTableViewDelegate?

    func set(title: String, checked: Bool) {
        titleLabel.text = title
        check.isChecked = checked
    }

    @IBAction func checkboxValueChanged(_ sender: Checkbox) {
        cellDelegate?.checkboxSelected(checkbox: self, settingValue: titleLabel.text!)
    }
}
