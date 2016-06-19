//
//  ColorGenerationViewController.swift
//  Mentor
//
//  Created by Alexandre barbier on 11/01/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ColorCell: UICollectionViewCell {
    
    @IBOutlet var quoteImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        quoteImageView.image = quoteImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        quoteImageView.tintColor  = UIColor.whiteColor()
        quoteImageView.hidden = true
    }
}

protocol ColorGenerationViewControllerDelegate {
    func didSelectColor(color:UIColor, seed:CGFloat)
}

class ColorGenerationViewController: UIViewController {
    
    @IBOutlet var colorCollectionView: UICollectionView!
    
    private var colorDataSource:[(color:UIColor, colorSeed:CGFloat)] = []
    private var selectedIndex = -1
    var delegate:ColorGenerationViewControllerDelegate?
    var loadFromNil = false
}

// MARK: - View lifecycle
extension ColorGenerationViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        ColorGenerator.CGSharedInstance.readyBlock = { (ready) in
            self.colorDataSource = Array<(color:UIColor, colorSeed:CGFloat)>(count: 12, repeatedValue: (UIColor.whiteColor(), 0))
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.colorCollectionView.reloadData()
            })
        }
        if !loadFromNil {
            if let lastOpenedteamProject = Project.getLastOpen() {
                ColorGenerator.CGSharedInstance.team = lastOpenedteamProject.team!
            }
        }
        else {
            ColorGenerator.CGSharedInstance.currentSeed = 0
            ColorGenerator.CGSharedInstance.readyBlock!(ready:true)
        }
        
    }
}

// MARK: - CollectionView
extension ColorGenerationViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureColorCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        cell.rounded(4)
        if colorDataSource[index.row].color == UIColor.whiteColor() {
            colorDataSource[index.row] = ColorGenerator.CGSharedInstance.getNextColor()!
            cell.backgroundColor = colorDataSource[index.row].color
        }
        else {
            cell.backgroundColor = colorDataSource[index.row].color
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colorDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath) as! ColorCell
        configureColorCellForIndexPath(cell, index: indexPath)
        cell.quoteImageView.hidden = selectedIndex != indexPath.row
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            delegate.didSelectColor(colorDataSource[indexPath.row].color, seed:colorDataSource[indexPath.row].colorSeed)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let delegate = delegate {
            selectedIndex = indexPath.row
            colorCollectionView.reloadData()
            delegate.didSelectColor(colorDataSource[indexPath.row].color, seed:colorDataSource[indexPath.row].colorSeed)
        }
    }
}