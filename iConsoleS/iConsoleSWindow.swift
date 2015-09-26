//
//  iConsoleSWindow.swift
//  iConsoleS
//
//  Created by Jacob Mao on 15/9/26.
//  Copyright © 2015年 JacobMao. All rights reserved.
//

import UIKit

class iConsoleSWindow: UIWindow {
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion != .MotionShake {
            return super.motionEnded(motion, withEvent: event)
        }
        
        
    }
}
