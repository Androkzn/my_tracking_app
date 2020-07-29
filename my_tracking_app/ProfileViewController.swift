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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    @IBAction func ageTextFieldBeginEditing(_ sender: UITextField) {
        print("ageStartEditing")
        let ageRows:[Int] = Array(1...100)
        textFieldPicker(sender, rows: ageRows,  title: "Select your age")
        view.endEditing(true)
    }

    @IBAction func genderTextFieldBeginEditing(_ sender: UITextField) {
        print("genderStartEditing")
        let genderRows:[String] = ["Male", "Female", "Other"]
        textFieldPicker(sender, rows: genderRows,  title: "Select your gender")
        view.endEditing(true)
        
    }
    
    @IBAction func weightTextFieldBeginEditing(_ sender: UITextField) {
        print("weightStartEditing")
        let ageRows:[Int] = Array(1...200)
        textFieldPicker(sender, rows: ageRows,  title: "Select your weight")
        view.endEditing(true)
         
    }
    
    @IBAction func heightTextFieldBeginEditing(_ sender: UITextField) {
        print("heightStartEditing")
        let ageRows:[Int] = Array(1...250)
        textFieldPicker(sender, rows: ageRows,  title: "Select your height")
        view.endEditing(true)
        
    }
    
    func textFieldPicker(_ sender: UITextField, rows: [Any], title: String) {
        let picker = ActionSheetStringPicker(title: title,
                                     rows: rows,
                                     initialSelection: rows.count/3,
                                     doneBlock: { picker, value, index in
                                        //printings
                                        print("picker = \(String(describing: picker))")
                                        print("value = \(value)")
                                        print("index = \(String(describing: index))")
                                        sender.text = "\(index!)"
                                        return
                                     },
                                     cancel: { picker in
                                        return
                                     },
                                     origin: sender)
     
        // customize appearance of the picker
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        picker!.pickerTextAttributes = [NSAttributedString.Key.paragraphStyle: paragraph, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20.0)]
        picker!.setTextColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
        picker!.pickerBackgroundColor = #colorLiteral(red: 1, green: 0.8085083365, blue: 0.4892358184, alpha: 1)
        picker!.toolbarBackgroundColor = #colorLiteral(red: 0.3249011148, green: 0.7254286438, blue: 0.9069467254, alpha: 0.8043396832)
        //right button
        let okButton = UIButton()
        okButton.setTitle("OK", for: .normal)
        okButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        let customDoneButton = UIBarButtonItem.init(customView: okButton)
        picker!.setDoneButton(customDoneButton)
        //left button
        let cancelButton = UIButton()
        cancelButton.setTitle("CANCEL", for: .normal)
        cancelButton.setTitleColor(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), for: .normal)
        let customCancelButton = UIBarButtonItem.init(customView: cancelButton)
        picker!.setCancelButton(customCancelButton)
        
        picker!.show()      }
    
}

    
