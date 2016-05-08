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
}

// MARK: - View lifecycle
extension ToolsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        colorIndicatorView.rounded(4)
    }
}

// MARK: - CollectionView
extension ToolsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
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
             var cell = collectionView.dequeueReusableCellWithReuseIdentifier("toolsCell", forIndexPath: indexPath)
            configureToolsCellForIndexPath(&cell, index: indexPath)
            return cell
        }
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("colorCell", forIndexPath: indexPath)
        configureColorCellForIndexPath(&cell, index: indexPath)
        return cell
    }
    
    func configureToolsCellForIndexPath(inout cell: UICollectionViewCell, index: NSIndexPath) {
        
    }
    
    func configureColorCellForIndexPath(inout cell: UICollectionViewCell, index: NSIndexPath) {
        cell.backgroundColor = colorDataSource[index.row]
    }
    
}
