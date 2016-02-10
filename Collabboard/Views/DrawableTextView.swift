//
//  DrawableTextView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 10/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class DrawableTextView: UITextView, UITextViewDelegate {
    
    
    class func create(origin:CGPoint, text:String, color:UIColor) -> DrawableTextView {
        let screenSize = UIScreen.mainScreen().bounds.size
        let maxSize = CGSize(width: screenSize.width - origin.x, height: screenSize.height - origin.y)
        let textView = DrawableTextView(frame: CGRect(origin: origin, size: maxSize))
        textView.backgroundColor = UIColor.clearColor()
        textView.font = UIFont.systemFontOfSize(18.0)
        textView.text = text
        textView.textColor = color
        textView.delegate = textView


        textView.returnKeyType = .Done

        return textView
    }
    
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.resignFirstResponder()
            return false
        }
        return true
    }
    
    override func shouldChangeTextInRange(range: UITextRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.resignFirstResponder()
            return false
        }
        return true
    }
    
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
    // Drawing code
    }
    */
    
}
