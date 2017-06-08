//
//  iConsoleSViewController.swift
//  iConsoleS
//
//  Created by Jacob Mao on 15/9/26.
//  Copyright © 2015年 JacobMao. All rights reserved.
//

import UIKit

typealias T_CloseConsoleBlockType = () -> Void

class iConsoleSViewController: UIViewController {
    // MARK: Views
    private lazy var infoTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.textColor = Style.textColor
        textView.backgroundColor = Style.backgroundColor
        textView.indicatorStyle = Style.indicatorStyle
        textView.font = Style.textFont
        textView.alwaysBounceVertical = true
        
        return textView
    }()
    
    private lazy var actionButton: UIButton = {
        let but = UIButton(type: .custom)
        but.setTitle("⚙", for: .normal)
        but.setTitleColor(Style.textColor, for: .normal)
        but.setTitleColor(Style.textColor.withAlphaComponent(0.5), for: .highlighted)
        but.titleLabel?.font = but.titleLabel?.font.withSize(Style.touchAreaOfActionButton.width)
        but.autoresizingMask = []
        
        but.addTarget(self, action: #selector(iConsoleSViewController.clickedActionButton), for: .touchUpInside)
        
        return but
    }()
    
    // MARK: Properties
    private struct Style {
        static let backgroundColor: UIColor = UIColor.black
        static let textColor: UIColor = UIColor.white
        static let indicatorStyle: UIScrollViewIndicatorStyle = .white
        static let textFont: UIFont? = UIFont(name: "Courier", size: 12)
        static let touchAreaOfActionButton: CGSize = CGSize(width: 40, height: 40)
    }
    
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
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        setupTextView()
        setupActionButton()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func log(_ logMessage: String) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.infoTextView.text = strongSelf.infoTextView.text + ">>> " + logMessage + "\n"
        }
    }
}

// MARK: Private Methods
private extension iConsoleSViewController {
    func encodeString(_ rawString: String) -> String? {
        return rawString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    func setupTextView() {
        if infoTextView.superview == nil {
            view.addSubview(infoTextView)
        }
        
        infoTextView.frame = view.bounds
    }
    
    func setupActionButton() {
        if actionButton.superview == nil {
            view.addSubview(actionButton)
        }
        
        let xOffset = view.bounds.size.width - Style.touchAreaOfActionButton.width - 5
        let yOffset = view.bounds.size.height - Style.touchAreaOfActionButton.height - 5
        actionButton.frame = CGRect(x: xOffset,
                                    y: yOffset,
                                    width: Style.touchAreaOfActionButton.width,
                                    height: Style.touchAreaOfActionButton.height)
    }
    
    // MARK: Alert Actions
    var sendMailAction: UIAlertAction {
        return UIAlertAction(title: "Send by Email", style: .default) { [weak self] (action) in
            guard let strongSelf = self,
                let encodedSubject = strongSelf.encodeString("log from iConsoleS"),
                let encodedContent = strongSelf.encodeString(strongSelf.infoTextView.text) else {
                    return
            }
            
            let urlString = "mailto:?subject=\(encodedSubject)&body=\(encodedContent)"
            if let mailURL = URL(string: urlString) {
                UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    var closeAction: UIAlertAction {
        return UIAlertAction(title: "Close Console", style: .default) { [weak self] (action) in
            self?.closeConsoleBlock?()
        }
    }
    
    var gotoTopAction: UIAlertAction {
        return UIAlertAction(title: "Go to Top", style: .default) { [weak self] (action) in
            self?.infoTextView.scrollRangeToVisible(NSMakeRange(0, 0))
        }
    }
    
    var gotoBottomAction: UIAlertAction {
        return UIAlertAction(title: "Go to Bottom", style: .default) { [weak self] (action) in
            guard let strongSelf = self else {
                return;
            }
            
            let scrollRect = CGRect(x: 0,
                                    y: strongSelf.infoTextView.contentSize.height - 1,
                                    width: strongSelf.infoTextView.contentSize.width,
                                    height: 1)
            strongSelf.infoTextView.scrollRectToVisible(scrollRect, animated: true)
        }
    }
    
    var clearAction: UIAlertAction {
        return UIAlertAction(title: "Clear Log", style: .destructive) { [weak self] (action) in
            self?.infoTextView.text = nil
        }
    }
    
    // MARK: UI Actions
    @objc func clickedActionButton(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(sendMailAction)
        alertController.addAction(closeAction)
        alertController.addAction(gotoTopAction)
        alertController.addAction(gotoBottomAction)
        alertController.addAction(clearAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleSwipeGesture(gesture: UISwipeGestureRecognizer) {
        if gesture.state == .ended {
            closeConsoleBlock?()
        }
    }
}
