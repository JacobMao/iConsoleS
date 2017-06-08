//
//  iConsoleSWindow.swift
//  iConsoleS
//
//  Created by Jacob Mao on 15/9/26.
//  Copyright © 2015年 JacobMao. All rights reserved.
//

import UIKit

func logToiConsoleS(message: String) {
    defer {
        NSLog(message)
    }
    
    guard let currentKeyWindow = UIApplication.shared.keyWindow,
          let consoleWindow = currentKeyWindow as? iConsoleSWindow else {
        return;
    }
    
    consoleWindow.log(message)
}

class iConsoleSWindow: UIWindow {
    // MARK: Private Properties
    private lazy var consoleVC: iConsoleSViewController = {
        let res = iConsoleSViewController(closeConsoleBlock: { [weak self] () -> Void in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self?.hideConsole()
            })
        })
        
        return res
    }()
    
    private var isAnimating = false
    
    // MARK: Methods
    override func motionEnded(_ motion: UIEventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            if consoleVC.view.superview == nil {
                showConsole()
            } else {
                hideConsole()
            }
        }
        
        return super.motionEnded(motion, with: event)
    }
    
    override func layoutSubviews() {
        consoleVC.view.frame = bounds
        
        super.layoutSubviews()
    }
    
    func log(_ logMessage: String) {
        consoleVC.log(logMessage)
    }
    
    private func showConsole() {
        if isAnimating {
            return
        }
        
        findAndResignFirstResponder(rootView: self)
        
        
        addSubview(consoleVC.view)
        consoleVC.view.center = CGPoint(x: center.x, y: center.y + bounds.maxY)
        
        isAnimating = true
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.consoleVC.view.center = self.center
        }) { (_) in
            self.isAnimating = false
        }
    }
    
    private func hideConsole() {
        if isAnimating {
            return
        }
        
        isAnimating = true
        UIView.animate(withDuration: 0.3,
                       animations: {
                        self.consoleVC.view.center = CGPoint(x: self.center.x, y: self.center.y + self.bounds.maxY)
        }) { (_) in
            self.isAnimating = false
            self.consoleVC.view.removeFromSuperview()
        }
    }
    
    @discardableResult
    private func findAndResignFirstResponder(rootView: UIView) -> Bool {
        if rootView.isFirstResponder {
            rootView.resignFirstResponder()
            return true
        }
        
        for nextView in rootView.subviews {
            if findAndResignFirstResponder(rootView: nextView) {
                return true
            }
        }
        
        return false
    }
}
