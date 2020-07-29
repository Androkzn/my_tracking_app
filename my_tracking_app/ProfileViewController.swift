//
//  ProfileViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-28.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import UIKit
import CoreActionSheetPicker

class ProfileViewController: UIViewController {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func navigationBarItemPicker(_ sender: UIBarButtonItem) {
        // example of string picker with done and cancel blocks
        ActionSheetStringPicker.show(withTitle: "Picker from navigation bar",
                                     rows: ["One", "Two", "A lot"],
                                     initialSelection: 1,
                                     doneBlock: { picker, value, index in
                                        print("picker = \(String(describing: picker))")
                                        print("value = \(value)")
                                        print("index = \(String(describing: index))")
                                        return
                                     },
                                     cancel: { picker in
                                        return
                                     },
                                     origin: sender)
    }
    

}
