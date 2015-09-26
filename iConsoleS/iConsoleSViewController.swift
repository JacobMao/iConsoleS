//
//  iConsoleSViewController.swift
//  iConsoleS
//
//  Created by Jacob Mao on 15/9/26.
//  Copyright © 2015年 JacobMao. All rights reserved.
//

import UIKit

typealias T_CloseConsoleBlockType = () -> Void

struct iConsoleSStyle {
    var backgroundColor: UIColor = UIColor.blackColor()
    var textColor: UIColor = UIColor.whiteColor()
    var indicatorStyle: UIScrollViewIndicatorStyle = .White
}

class iConsoleSViewController: UIViewController {
    // MARK: Views
    private lazy var infoTextView: UITextView = {
        let textView = UITextView()
        textView.editable = false
        textView.textColor = self.myStyle.textColor
        textView.backgroundColor = self.myStyle.backgroundColor
        textView.indicatorStyle = self.myStyle.indicatorStyle
        textView.font = UIFont(name: "Courier", size: 12)
        textView.alwaysBounceVertical = true
        
        return textView
    }()
    
    private lazy var actionButton: UIButton = {
        let but = UIButton(type: .Custom)
        but.setTitle("⚙", forState: .Normal)
        but.setTitleColor(self.myStyle.textColor, forState: .Normal)
        but.setTitleColor(self.myStyle.textColor.colorWithAlphaComponent(0.5), forState: .Highlighted)
        but.titleLabel?.font = but.titleLabel?.font.fontWithSize(iConsoleSViewController.touchAreaOfActionButton.width)
        but.autoresizingMask = [.None]
        
        but.addTarget(self, action: "clickedActionButton:", forControlEvents: .TouchUpInside)
        
        
        return but
    }()
    
    // MARK: Properties
    var myStyle: iConsoleSStyle = iConsoleSStyle()
    static private let touchAreaOfActionButton = CGSizeMake(40, 40)
    
    let closeConsoleBlock: T_CloseConsoleBlockType?
    
    // MARK: - Life Cycle
    init(closeConsoleBlock: T_CloseConsoleBlockType?) {
        self.closeConsoleBlock = closeConsoleBlock
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.closeConsoleBlock = nil
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.infoTextView.superview == nil {
            self.view.addSubview(self.infoTextView)
        }
        self.infoTextView.frame = self.view.bounds
        
        if self.actionButton.superview == nil {
            self.view.addSubview(self.actionButton)
        }
        let xOffset = self.view.bounds.size.width - iConsoleSViewController.touchAreaOfActionButton.width - 5
        let yOffset = self.view.bounds.size.height - iConsoleSViewController.touchAreaOfActionButton.height - 5
        self.actionButton.frame = CGRectMake(xOffset, yOffset,
            iConsoleSViewController.touchAreaOfActionButton.width,
            iConsoleSViewController.touchAreaOfActionButton.height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func log(logMessage: String) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.infoTextView.text = strongSelf.infoTextView.text + ">>> " + logMessage + "\n"
        }
    }
    
    private func encodeString(rawString: String) -> String? {
        let rawNSString: NSString = rawString
        guard let encodedString = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            rawNSString,
            "[].",
            ":/?&=;+!@#$()',*",
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) else {
                return nil;
        }
        
        return encodedString as String
    }
    
    // MARK: UI Actions
    @objc private func clickedActionButton(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
        }
        alertController.addAction(cancelAction)
        
        let sendMailAction = UIAlertAction(title: "Send by Email", style: .Default) { [weak self] (action) in
            guard let strongSelf = self else {
                return
            }
            
            guard let encodedSubject = strongSelf.encodeString("log from iConsoleS") else {
                return
            }
            
            guard let encodedContent = strongSelf.encodeString(strongSelf.infoTextView.text) else {
                return
            }
            
            let urlString = "mailto:?subject=\(encodedSubject)&body=\(encodedContent)"
            
            if let mailURL = NSURL(string: urlString) {
                UIApplication.sharedApplication().openURL(mailURL)
            }
        }
        alertController.addAction(sendMailAction)
        
        let closeAction = UIAlertAction(title: "Close Console", style: .Default) { [weak self] (action) in
            self?.closeConsoleBlock?()
        }
        alertController.addAction(closeAction)
        
        let gotoTopAction = UIAlertAction(title: "Go to Top", style: .Default) { [weak self] (action) in
            self?.infoTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        }
        alertController.addAction(gotoTopAction)

        let gotoBottomAction = UIAlertAction(title: "Go to Bottom", style: .Default) { [weak self] (action) in
            guard let strongSelf = self else {
                return;
            }
            
            strongSelf.infoTextView.scrollRectToVisible(CGRectMake(0,
                strongSelf.infoTextView.contentSize.height - 1,
                strongSelf.infoTextView.contentSize.width,
                1), animated: true)
        }
        alertController.addAction(gotoBottomAction)
        
//        let gotoBottomAction = UIAlertAction(title: "Go to Bottom", style: .Default) { [weak self] (action) in
//            self?.infoTextView.scrollRectToVisible(CGRectZero, animated: YES)
//        }
//        alertController.addAction(gotoBottomAction)
        
        let clearAction = UIAlertAction(title: "Clear Log", style: .Destructive) { [weak self] (action) in
            self?.infoTextView.text = nil
        }
        alertController.addAction(clearAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == .Ended {
            self.closeConsoleBlock?()
        }
    }
}

