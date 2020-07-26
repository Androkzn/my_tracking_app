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
        setupLabelTap()
    }
    //Set up gesture recognizer for the label
    func setupLabelTap() {
        let labelTap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
        self.titleLabel.isUserInteractionEnabled = true
        self.titleLabel.addGestureRecognizer(labelTap)
        
    }
    //conects the label to checkbox
    @objc func labelTapped(_ sender: UITapGestureRecognizer) {
        cellDelegate?.checkboxSelected(checkbox: self, settingValue: titleLabel.text!)
    }
    
    @IBAction func checkboxTapped(_ sender: Checkbox) {
        cellDelegate?.checkboxSelected(checkbox: self, settingValue: titleLabel.text!)
    }
}
