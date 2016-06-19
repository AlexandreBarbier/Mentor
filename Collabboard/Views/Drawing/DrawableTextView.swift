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
        let textView : DrawableTextView = {
            $0.backgroundColor = UIColor.clearColor()
            $0.font = UIFont.Roboto(.Regular, size: 18.0)
            $0.text = text
            $0.textColor = color
            $0.delegate = $0
            $0.returnKeyType = .Done
            return $0
        } (DrawableTextView(frame: CGRect(origin: origin, size: maxSize)))
        

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
}
