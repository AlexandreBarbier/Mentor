//
//  SocialTextView.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 24/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

public class SocialTextView : UITextView {

    @IBInspectable public var mentionColor : UIColor = UIColor.redColor()
    @IBInspectable public var tagsColor : UIColor = UIColor.greenColor()
    
    public var mentions = [AnyObject]()
    public var tags = [AnyObject]()

    private let _textQueue_ = NSOperationQueue()
    private let mentionRegex = try! NSRegularExpression(pattern:"@[A-Za-z0-9_]+", options: NSRegularExpressionOptions.CaseInsensitive)
    private let tagRegex = try! NSRegularExpression(pattern:"#[A-Za-z0-9_]+", options: NSRegularExpressionOptions.CaseInsensitive)
    private let defaultAttributes = [String : AnyObject]()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        self.initTextView()
    }
    private func initTextView() -> Void {
        self.scrollEnabled = false
        self.editable = false;
        self.userInteractionEnabled = true
        super.linkTextAttributes = [:]
        self.dataDetectorTypes = UIDataDetectorTypes.All
        self.textContainer.lineFragmentPadding = 0
        self.textContainerInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        self.initTextView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initTextView()
    }
    

    
    public override func canPerformAction(action: Selector, withSender sender: AnyObject!) -> Bool {
        if (action == Selector("copy")) {
            return super.canPerformAction(action, withSender: sender)
        }
        return false
    }
    
    public override var text : String! {
        get {return super.text}
        set {

            
            self.mentions = self.mentionRegex.matchesInString(newValue, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, newValue.characters.count))
            self.tags = self.tagRegex.matchesInString(newValue, options: NSMatchingOptions.ReportCompletion, range: NSMakeRange(0, newValue.characters.count))
            let str = NSMutableAttributedString(string: newValue, attributes: self.defaultAttributes)
            
            for result in self.mentions {
                let res = result as! NSTextCheckingResult
                let range = NSRange(location:res.range.location + 1, length:res.range.length - 1)
                let lastChar = [unichar](newValue.utf16)[result.range.location - 1]
                let nsstr = newValue as NSString
                if (range.location - 1 == 0 || NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(lastChar)){
                    str.addAttributes([NSLinkAttributeName :"username://\(nsstr.substringWithRange(range))", NSForegroundColorAttributeName : self.mentionColor] ,range:result.range)
                }
            }
            for result in self.tags {
                let res = result as! NSTextCheckingResult
                let range = NSRange(location:res.range.location + 1, length:res.range.length - 1)
                let lastChar = [unichar](newValue.utf16)[result.range.location - 1]
                let nsstr = newValue as NSString
                if (range.location - 1 == 0 || NSCharacterSet.whitespaceAndNewlineCharacterSet().characterIsMember(lastChar)){
                    str.addAttributes([NSLinkAttributeName :"tag://\(nsstr.substringWithRange(range))", NSForegroundColorAttributeName : self.tagsColor] ,range:result.range)
                }
            }

            self.attributedText = str;
        }
    }
}
