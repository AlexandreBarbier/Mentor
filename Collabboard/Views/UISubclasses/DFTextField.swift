//
//  DFTextField.swift
//  Collabboard
//
//  Created by Alexandre barbier on 21/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

@IBDesignable
class DFTextField: UITextField {
    
    @IBInspectable
    var icon : UIImage? {
        didSet {
            guard let icon = icon else {
                return
            }
            
            let img = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
            leftView = UIView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: img.frame.width + 16 + padding.left, height: self.frame.height)))
            let y = (leftView!.frame.height - img.frame.height) / 2
            img.frame = CGRect(origin: CGPoint(x: 8, y: y), size: img.frame.size)
            let sepView = UIView(frame: CGRect(x: (img.center.x * 2) - 1, y: 6, width: 1, height: leftView!.frame.height - 12))
            sepView.backgroundColor = borderColor
            leftView!.addSubview(img)
            leftView!.addSubview(sepView)
            
        }
    }
    
    var padding = UIEdgeInsets.zero
    
    @IBInspectable
    var cornerRadius : CGFloat = 0.0 {
        didSet {
            self.rounded(cornerRadius)
        }
    }
    
    @IBInspectable
    var borderW : CGFloat = 1 {
        didSet {
            self.border(borderColor, width: borderW)
        }
    }
    
    var innerColor = UIColor.black {
        didSet {
            tintColor = innerColor
            textColor = innerColor
        }
    }
    
    @IBInspectable
    var borderColor : UIColor = UIColor.black {
        didSet {
            self.border(borderColor, width: borderW)
        }
    }
    
    func setup(_ icon: UIImage? = nil, border: UIColor? = nil, innerColor: UIColor? = nil, cornerRadius: CGFloat? = nil) {
        leftViewMode = .always
        if let border = border {
            borderColor = border
        }
        if let icon = icon {
            self.icon = icon
        }
        else {
            if padding != UIEdgeInsets.zero {
                leftView = UIView(frame: CGRect(x: 0, y: 0, width: padding.left, height: frame.height))
            }
        }
        if let cornerRadius = cornerRadius {
            self.cornerRadius = cornerRadius
        }
        if let innerColor = innerColor {
            self.innerColor = innerColor
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
