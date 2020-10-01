//
//  ToastView.swift
//  my_tracking_app
//
//  Created by Andrei Tekhtelev on 2020-07-13.
//  Copyright © 2020 HomeFoxDev. All rights reserved.
//

import Foundation
import UIKit

open class ToastView: UILabel {
    
    var overlayView = UIView()
    var lbl = UILabel()
    
    class var shared: ToastView {
        struct Static {
            static let instance: ToastView = ToastView()
        }
        return Static.instance
    }
    
    func setup(_ view: UIView,txt_msg:String) {
        overlayView.frame = CGRect(x: 0, y: 0, width: view.frame.width - 60  , height: 50)
        overlayView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height - 400)
        overlayView.backgroundColor = #colorLiteral(red: 0.1391149759, green: 0.3948251009, blue: 0.5650185347, alpha: 1)
        overlayView.clipsToBounds = true
        overlayView.layer.cornerRadius = 10
        overlayView.alpha = 0
        
        lbl.frame = CGRect(x: 0, y: 0, width: overlayView.frame.width, height: 50)
        lbl.numberOfLines = 0
        lbl.textColor = UIColor.white
        lbl.center = overlayView.center
        lbl.text = txt_msg
        lbl.textAlignment = .center
        lbl.center = CGPoint(x: overlayView.bounds.width / 2, y: overlayView.bounds.height / 2)
        overlayView.addSubview(lbl)
        view.addSubview(overlayView)
    }
    
    open func blueToast(_ view: UIView,txt_msg:String, duration: Double) {
        
        self.setup(view, txt_msg: txt_msg)
        //Animation
        UIView.animate(withDuration: duration, animations: {
            self.overlayView.alpha = 1
        })
        { (true) in
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 0
            })
        }
    }
    
    open func redToast(_ view: UIView,txt_msg:String, duration: Double) {
        self.setup(view, txt_msg: txt_msg)
        overlayView.backgroundColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        //Animation
        UIView.animate(withDuration: duration, animations: {
            self.overlayView.alpha = 1
        })
        { (true) in
            UIView.animate(withDuration: 1, animations: {
                self.overlayView.alpha = 0
            })
        }
    }
    
    func stopAnimation () {
        overlayView.layer.removeAllAnimations()
    }
}

