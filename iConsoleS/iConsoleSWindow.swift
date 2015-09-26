//
//  iConsoleSWindow.swift
//  iConsoleS
//
//  Created by Jacob Mao on 15/9/26.
//  Copyright © 2015年 JacobMao. All rights reserved.
//

import UIKit

func logToiConsoleS(message: String) {
    guard let currentKeyWindow = UIApplication.sharedApplication().keyWindow else {
        return;
    }
    
    guard let consoleWindow = currentKeyWindow as? iConsoleSWindow else {
        return;
    }
    
    consoleWindow.log(message)
}

class iConsoleSWindow: UIWindow {
    // MARK: Private Properties
    private lazy var consoleVC: iConsoleSViewController = {
        let res = iConsoleSViewController(closeConsoleBlock: { [weak self] () -> Void in
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(UInt64(0.5)*NSEC_PER_SEC)),
                dispatch_get_main_queue()) { () -> Void in
                    self?.hideConsole()
            }
        })
        
        return res
    }()
    
    private var isAnimating = false
    
    // MARK: Methods
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
        if motion == .MotionShake {
            if self.consoleVC.view.superview == nil {
                self.showConsole()
            } else {
                self.hideConsole()
            }
        }
        
        return super.motionEnded(motion, withEvent: event)
    }
    
    override func layoutSubviews() {
        self.consoleVC.view.frame = self.bounds
        
        super.layoutSubviews()
    }
    
    func log(logMessage: String) {
        self.consoleVC.log(logMessage)
    }
    
    private func showConsole() {
        if self.isAnimating {
            return
        }
        
        self.findAndResignFirstResponder(self)
        
        self.addSubview(self.consoleVC.view)
        self.consoleVC.view.center = CGPointMake(self.center.x,
            self.center.y + CGRectGetMaxY(self.bounds))
        
        self.isAnimating = true
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.consoleVC.view.center = self.center
            }) { (finished: Bool) -> Void in
                self.isAnimating = false
        }
    }
    
    private func hideConsole() {
        if self.isAnimating {
            return
        }
        
        self.isAnimating = true
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.consoleVC.view.center = CGPointMake(self.center.x,
                    self.center.y + CGRectGetMaxY(self.bounds))
            }) { (finished: Bool) -> Void in
                self.isAnimating = false
                self.consoleVC.view.removeFromSuperview()
        }
    }
    
    private func findAndResignFirstResponder(view: UIView) -> Bool {
        if view.isFirstResponder() {
            view.resignFirstResponder()
            return true
        }
        
        for nextView in view.subviews {
            if self.findAndResignFirstResponder(nextView) {
                return true
            }
        }
        
        return false
    }
}
