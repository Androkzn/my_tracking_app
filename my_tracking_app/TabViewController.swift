//
//  TabViewController.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import UIKit

class TabViewController: UITabBarController {

    //selects the first view (Map) as main view
    override open func viewDidLoad() {
        super.viewDidLoad()
        selectedIndex = 1
        UITabBar.appearance().unselectedItemTintColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
    }
    
}
