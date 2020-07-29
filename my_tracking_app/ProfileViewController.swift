//
//  ProfileViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-28.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class ProfileViewController: UIViewController {

    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func ageTextFieldBeginEditing(_ sender: UITextField) {
        print("ageStartEditing")
        let ageRows:[Int] = Array(1...150)
        textFieldPicker(sender, rows: ageRows,  title: "Select your age")
    }

    @IBAction func genderTextFieldBeginEditing(_ sender: UITextField) {
        print("genderStartEditing")
        let genderRows:[String] = ["Male", "Female", "Other"]
        textFieldPicker(sender, rows: genderRows,  title: "Select your gender")
        
    }
    
    @IBAction func weightTextFieldBeginEditing(_ sender: UITextField) {
        print("weightStartEditing")
        let ageRows:[Int] = Array(1...300)
        textFieldPicker(sender, rows: ageRows,  title: "Select your weight")
         
    }
    
    @IBAction func heightTextFieldBeginEditing(_ sender: UITextField) {
        print("heightStartEditing")
        let ageRows:[Int] = Array(1...250)
        textFieldPicker(sender, rows: ageRows,  title: "Select your height")
        
    }
    
    func textFieldPicker(_ sender: UITextField, rows: [Any], title: String) {
        ActionSheetStringPicker.show(withTitle: title,
                                     rows: rows,
                                     initialSelection: 1,
                                     doneBlock: { picker, value, index in
                                        //printings
                                        print("picker = \(String(describing: picker))")
                                        print("value = \(value)")
                                        print("index = \(String(describing: index))")
                                        sender.text = "\(index!)"
                                        self.view.endEditing(true)
                                        return
                                     },
                                     cancel: { picker in
                                        return
                                     },
                                     origin: sender)
        
    }
    
    
    
    
    
}

extension ProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        print("textFieldSentData")
        if textField == ageTextField {
            print("age")
            let age = textField.text ?? ""
        }
        if textField == genderTextField {
            print("gender")
            let gender = textField.text ?? ""
        }
        if textField == weightTextField {
            print("weight")
            let weight = textField.text ?? ""
    
        }
        if textField == heightTextField {
            print("height")
            let height = textField.text ?? ""

        }
        return true
    }
}
    
