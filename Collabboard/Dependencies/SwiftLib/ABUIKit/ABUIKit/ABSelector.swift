//
//  ABSelector.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 27/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

@IBDesignable open class ABSelector : UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak open var selectorCollectionView: UICollectionView!
    @IBInspectable open var numberOfItem : Int = 0
    @IBInspectable open var cellId : String = ""
    
    fileprivate var internalCellId : String {
        get {
            if (cellId == "") {
                fatalError("init(coder:) has not been implemented")
            }
            return cellId
        }
    }
    
    @IBInspectable open var radius : CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    open override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width / CGFloat(numberOfItem)), height: self.frame.size.height)
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItem
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return selectorCollectionView.dequeueReusableCell(withReuseIdentifier: internalCellId, for: indexPath) as UICollectionViewCell
    }
}
