//
//  ToolsViewController.swift
//  Collabboard
//
//  Created by Alexandre barbier on 08/05/16.
//  Copyright © 2016 Alexandre Barbier. All rights reserved.
//

import UIKit

class ToolsViewController: UIViewController {
    @IBOutlet weak var colorIndicatorView: UIView!
    @IBOutlet weak var toolsCollectionView: UICollectionView!
    @IBOutlet weak var colorCollectionView: UICollectionView!
    @IBOutlet weak var sizeSlider: UISlider!
    
    private var toolsDataSource = ["pen", "marker"]
    private var colorDataSource:[UIColor] = []
    
    var currentColor:UIColor!
}

// MARK: - View lifecycle
extension ToolsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        colorIndicatorView.rounded(4)
        colorIndicatorView.backgroundColor = currentColor
        ColorGenerator.CGSharedInstance.readyBlock = { (ready) in
            self.colorDataSource = Array<UIColor>(count: 12, repeatedValue: UIColor.whiteColor())
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.colorCollectionView.reloadData()
            })
        }
        if let lastOpenedteamProject = Project.getLastOpen() {
            ColorGenerator.CGSharedInstance.team = lastOpenedteamProject.team!
        }
    }
}

// MARK: - CollectionView
extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func configureToolsCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        cell.backgroundView = UIImageView(image: UIImage(named: toolsDataSource[index.row]))
    }
    
    func configureColorCellForIndexPath(cell: UICollectionViewCell, index: NSIndexPath) {
        cell.rounded(4)
        if colorDataSource[index.row] == UIColor.whiteColor() {
            cell.backgroundColor = ColorGenerator.CGSharedInstance.getNextColor()
            colorDataSource[index.row] = cell.backgroundColor!
        }
        else {
            cell.backgroundColor = colorDataSource[index.row]
        }
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == toolsCollectionView {
            return toolsDataSource.count
        }
        return colorDataSource.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView == toolsCollectionView {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("toolsCell", forIndexPath: indexPath)
            configureToolsCellForIndexPath(cell, index: indexPath)
            return cell
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath)
        configureColorCellForIndexPath(cell, index: indexPath)
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView == toolsCollectionView {
            
        }
        else {
            colorIndicatorView.backgroundColor = colorDataSource[indexPath.row]
        }
    }
}

extension ToolsViewController {
    
    @IBAction func onCloseTouch(sender: AnyObject) {
        ColorGenerator.CGSharedInstance.reset() 
        dismissViewControllerAnimated(true, completion: nil)
    }
}
