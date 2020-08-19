//
//  Watch.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-08-18.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import WatchConnectivity

class Watch {
    
    static let shared  = Watch()
    
    func checkWatchConnection () {
        if WCSession.isSupported() {
            print("WATCH is supported")
            let session = WCSession.default
            session.activate()

            if session.isPaired { // Check if the iPhone is paired with the Apple Watch
                          print("WATCH is connected")
            }
        }
    }
    
}
    

