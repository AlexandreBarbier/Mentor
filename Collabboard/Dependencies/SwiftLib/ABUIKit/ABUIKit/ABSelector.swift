//
//  ABSelector.swift
//  ABUIKit
//
//  Created by Alexandre Barbier on 27/08/14.
//  Copyright (c) 2014 abarbier. All rights reserved.
//

import UIKit

@IBDesignable public class ABSelector : UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak public var selectorCollectionView: UICollectionView!
    @IBInspectable public var numberOfItem : Int = 0
    @IBInspectable public var cellId : String = ""
    
    private var internalCellId : String {
        get {
            if (cellId == "") {
                fatalError("init(coder:) has not been implemented")
            }
            return cellId
        }
    }
    
    @IBInspectable public var radius : CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = radius
            self.layer.masksToBounds = true
        }
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: (self.frame.size.width / CGFloat(numberOfItem)), height: self.frame.size.height)
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItem
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return selectorCollectionView.dequeueReusableCellWithReuseIdentifier(internalCellId, forIndexPath: indexPath) as UICollectionViewCell
    }
}
