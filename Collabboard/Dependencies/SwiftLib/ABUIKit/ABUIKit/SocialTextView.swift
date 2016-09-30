//
//  SocialTextView.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 24/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

open class SocialTextView : UITextView {

    @IBInspectable open var mentionColor : UIColor = UIColor.red
    @IBInspectable open var tagsColor : UIColor = UIColor.green
    
    

    fileprivate let _textQueue_ = OperationQueue()
    fileprivate let mentionRegex = try! NSRegularExpression(pattern:"@[A-Za-z0-9_]+", options: NSRegularExpression.Options.caseInsensitive)
    fileprivate let tagRegex = try! NSRegularExpression(pattern:"#[A-Za-z0-9_]+", options: NSRegularExpression.Options.caseInsensitive)
    fileprivate let defaultAttributes = [String : AnyObject]()
    
    open var mentions = [AnyObject]()
    open var tags = [AnyObject]()
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        self.initTextView()
    }
    
    fileprivate func initTextView() -> Void {
        super.linkTextAttributes = [:]
        isScrollEnabled = false
        isEditable = false;
        isUserInteractionEnabled = true
        dataDetectorTypes = UIDataDetectorTypes.all
        textContainer.lineFragmentPadding = 0
        textContainerInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        initTextView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initTextView()
    }
    
    open override func canPerformAction(_ action: Selector, withSender sender: Any!) -> Bool {
        
        if (action == #selector(UIMenuController.copy)) {
            return super.canPerformAction(action, withSender: sender)
        }
        return false
    }
    
    open override var text : String! {
        get {return super.text}
        set {
            mentions = mentionRegex.matches(in: newValue, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, newValue.characters.count))
            tags = tagRegex.matches(in: newValue, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSMakeRange(0, newValue.characters.count))
            let str = NSMutableAttributedString(string: newValue, attributes: defaultAttributes)
            
            for result in self.mentions {
                let res = result as! NSTextCheckingResult
                let range = NSRange(location:res.range.location + 1, length:res.range.length - 1)
                let lastChar = [unichar](newValue.utf16)[result.range.location - 1]
                let nsstr = newValue as NSString
                if (range.location - 1 == 0 || CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(lastChar)!)){
                    str.addAttributes([NSLinkAttributeName :"username://\(nsstr.substring(with: range))", NSForegroundColorAttributeName : mentionColor] ,range:result.range)
                }
            }
            for result in self.tags {
                let res = result as! NSTextCheckingResult
                let range = NSRange(location:res.range.location + 1, length:res.range.length - 1)
                let lastChar = [unichar](newValue.utf16)[result.range.location - 1]
                let nsstr = newValue as NSString
                if (range.location - 1 == 0 || CharacterSet.whitespacesAndNewlines.contains(UnicodeScalar(lastChar)!)){
                    str.addAttributes([NSLinkAttributeName :"tag://\(nsstr.substring(with: range))", NSForegroundColorAttributeName : tagsColor] ,range:result.range)
                }
            }

            attributedText = str;
        }
    }
}
