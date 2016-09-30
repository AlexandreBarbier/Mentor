//
//  DrawableTextView.swift
//  Collabboard
//
//  Created by Alexandre barbier on 10/02/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class DrawableTextView: UITextView, UITextViewDelegate {
    var drawing:Drawing!
    class func create(_ origin:CGPoint, text:String, color:UIColor, drawing:Drawing) -> DrawableTextView {
        
        let screenSize = UIScreen.main.bounds.size
        let maxSize = CGSize(width: screenSize.width - origin.x, height: screenSize.height - origin.y)
        
        let textView : DrawableTextView = {
            $0.backgroundColor = UIColor.clear
            $0.font = UIFont.Roboto(.Regular, size: 18.0)
            $0.text = text
            $0.textColor = color
            $0.drawing = drawing
            $0.delegate = $0
            $0.returnKeyType = .done
            return $0
        } (DrawableTextView(frame: CGRect(origin: origin, size: maxSize)))
        

        return textView
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.resignFirstResponder()
            var red : CGFloat = 0.0
            var green : CGFloat = 0.0
            var blue : CGFloat = 0.0
            self.textColor!.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let _ = Text.create(self.drawing , x: NSNumber(frame.origin.x), y: frame.origin.y, text: self.text, save: true)
            cbFirebase.drawing.updateChildValues([FirebaseKey.text:["x": frame.origin.x, "y": frame.origin.y, "v": self.text,FirebaseKey.red:NSNumber(value: Float(red)),FirebaseKey.green:NSNumber(value: Float(green)), FirebaseKey.blue:NSNumber(value: Float(blue)),FirebaseKey.drawingUser:"\(User.currentUser!.recordId.recordName)"]])
            return false
        }
        return true
    }
    
    override func shouldChangeText(in range: UITextRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.resignFirstResponder()
            return false
        }
        return true
    }
}